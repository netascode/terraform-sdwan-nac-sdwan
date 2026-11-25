*** Settings ***
Documentation   Verify the banner configuration of the system feature profiles on SD-WAN Manager.
...             The expected values come from the data model, the actual values from the Manager API.
...             Self-contained example: the keywords it needs are defined in this file. The full
...             test suite uses the shared sdwan_common.resource instead.
...             Requires the environment variables SDWAN_URL, SDWAN_USERNAME and SDWAN_PASSWORD.
Name            System Profiles Banner Example
Suite Setup     Login SDWAN Manager
Suite Teardown  Logout SDWAN Manager
Default Tags    sdwan    config    feature_profiles    system_profiles    banner    example
Library         RequestsLibrary
Library         JMESPathLibrary
Library         Collections
Library         String

*** Variables ***
&{login_json}=   j_username=%{SDWAN_USERNAME=}   j_password=%{SDWAN_PASSWORD=}
&{headers}=   content-type=application/x-www-form-urlencoded

*** Keywords ***
Login SDWAN Manager
   [Documentation]   Log in to SD-WAN Manager with SDWAN_USERNAME and SDWAN_PASSWORD and create the
   ...   'sdwan_manager' session used by the tests.
   ${log_level}=   Set Log Level   NONE
   TRY
      ${m_headers}=   Get Session Headers
      Create Session   sdwan_manager   %{SDWAN_URL}   verify=${False}   disable_warnings=1   headers=${m_headers}
   FINALLY
      Set Log Level   ${log_level}
   END
   Verify Authentication

Get Session Headers
   [Documentation]   Log in and return the request headers with the CSRF token and the session cookie.
   Create Session   login   %{SDWAN_URL}   verify=${False}   disable_warnings=1   headers=${headers}
   ${response}=   Wait Until Keyword Succeeds   6x   10s   POST On Session   login   /j_security_check   data=${login_json}
   ${r_token}=   Wait Until Keyword Succeeds   6x   10s   GET On Session   login   /dataservice/client/token
   ${cookie}=   Get from dictionary   ${response.headers}   set-cookie
   ${r_cookie}=   Split string   ${cookie}   separator=;
   ${m_headers}=   Create Dictionary   X-XSRF-TOKEN=${r_token.text}   Cookie=${r_cookie[0]}   accept=application/json
   RETURN   ${m_headers}

Verify Authentication
   [Documentation]   Make a test request, so that invalid credentials fail the suite setup with a clear message.
   TRY
      ${test_response}=   GET On Session   sdwan_manager   /dataservice/client/server
   EXCEPT   *401*   type=GLOB
      Fail   Authentication failed: 401 Unauthorized. Check SDWAN_USERNAME and SDWAN_PASSWORD.
   EXCEPT   AS   ${error}
      ${short_error}=   Evaluate   str($error)[:200]
      Fail   Authentication failed: ${short_error}
   END

Logout SDWAN Manager
   [Documentation]   Log out of SD-WAN Manager.
   ${m_headers}=   Create Dictionary   accept=*/*
   Wait Until Keyword Succeeds   6x   10s   POST On Session   sdwan_manager   /logout   headers=${m_headers}

GET On Session With Retry
   [Arguments]   ${session}   ${url}   ${params}=${None}   ${headers}=${None}
   [Documentation]   Wrapper for GET On Session with automatic retries, for example for HTTP 429 responses.
   ${result}=   Wait Until Keyword Succeeds   5x   2s   GET On Session   ${session}   ${url}   params=${params}   headers=${headers}
   RETURN   ${result}

Should Be Equal Value Json String
   [Documentation]   Compare the value found with a JMESPath expression in the JSON with the expected value.
   [Arguments]   ${json}   ${jmes_path}   ${expected_value}=${EMPTY}   ${msg}=${EMPTY}   ${ignore_case}=${False}
   ${actual_value}=   Json Search String   ${json}   ${jmes_path}
   # Convert empty string to "not_defined" only when expected value is "not_defined"
   ${actual_value}=   Set Variable If   $actual_value == '' and $expected_value == 'not_defined'   not_defined   ${actual_value}
   Should Be Equal As Strings   ${expected_value}   ${actual_value}   values=False   ignore_case=${ignore_case}   msg=${msg} expected: '${expected_value}' and got: '${actual_value}'

Convert String To List If Needed
   [Documentation]   Convert a string that looks like a list, for example "[a, b]", to a list.
   [Arguments]    ${value}
   ${is_list_string}=    Run Keyword And Return Status    Should Match Regexp    ${value}    ^\\[.*\\]$
   IF    $is_list_string and not isinstance($value, list)
      # Convert input value string to list
      ${value}=    Evaluate    json.loads(r'''${value}'''.replace("'", '"'))    modules=json
   END
   RETURN    ${value}

Should Be Equal Value Json Yaml
   [Documentation]   Compare a parameter of the Manager payload with the data model. A parameter set as a value is
   ...   compared with the expected value, a parameter set as a variable with the expected variable name.
   [Arguments]    ${json}    ${json_path}    ${value}    ${var_value}    ${msg}
   ${opt_type}=    Json Search String    ${json}    ${json_path}.optionType
   IF    $opt_type == 'global'
      # Convert string representation of list to actual list if needed
      ${value}=    Convert String To List If Needed    ${value}
      ${type_check}=    Evaluate    type($value).__name__
      IF    '${type_check}' == 'list'
         ${actual_list}=    Json Search List    ${json}    ${json_path}.value
         ${actual_list}=    Evaluate    [str(x) for x in $actual_list]
         ${expected_list}=    Evaluate    [str(x) for x in $value]
         Lists Should Be Equal    ${expected_list}    ${actual_list}    ignore_order=True    msg=${msg} expected: '${value}' and got: '${actual_list}'
      ELSE
         ${actual}=    Json Search String    ${json}    ${json_path}.value
         # Convert empty string to "not_defined" only when expected value is "not_defined"
         ${actual}=    Set Variable If    $actual == '' and $value == 'not_defined'    not_defined    ${actual}
         Should Be Equal As Strings    ${value}    ${actual}    msg=${msg} expected: '${value}' and got: '${actual}'
      END
   ELSE IF    $opt_type == 'variable'
      ${actual}=    Json Search String    ${json}    ${json_path}.value
      # In JSON API payload the variables are in format {% raw %}"{{var_name}}"{% endraw %}. We need to extract "var_name"
      ${cleaned}=    Evaluate    '${actual}'.strip('{}')
      # Convert empty string to "not_defined" only when expected value is "not_defined"
      ${cleaned}=    Set Variable If    '${cleaned}' == '' and '${var_value}' == 'not_defined'    not_defined    ${cleaned}
      Should Be Equal As Strings    ${var_value}    ${cleaned}    msg=${msg}_variable expected: '${var_value}' and got: '${cleaned}'
   ELSE
      Should Be Equal As Strings    not_defined    ${value}    msg=${msg} expected: '${value}' and got: 'not_defined'
      Should Be Equal As Strings    not_defined    ${var_value}    msg=${msg}_variable expected: '${var_value}' and got: 'not_defined'
   END

Normalize Escapes Spaces
   [Documentation]   Replace escape sequences such as backslash-n, backslash-t and backslash-r, and consecutive
   ...   double spaces, with native Robot escaping syntax. The expected and the actual value are both normalized,
   ...   so that they are compared in the same form.
   [Arguments]   ${text}
   IF   isinstance($text, list)
      ${text}=   Set Variable   ${text}[0]
   END
   ${text}=   Convert To String   ${text}
   ${text}=   Replace String   ${text}   \\n   \n
   ${text}=   Replace String   ${text}   \\r   \r
   ${text}=   Replace String   ${text}   \\t   \t
   ${text}=   Replace String   ${text}   ${SPACE}${SPACE}   \${SPACE}\${SPACE}
   ${text}=   Replace String   ${text}   \\x0d   \r
   ${text}=   Replace String   ${text}   \\x0a   \n
   ${text}=   Replace String   ${text}   \\x09   \t
   RETURN   ${text}

Should Be Equal Value Json Special_String
   [Documentation]   Same as 'Should Be Equal Value Json String', but special characters and spaces are normalized
   ...   in the expected and the actual value.
   [Arguments]   ${json}   ${jmes_path}   ${expected_value}=${EMPTY}   ${msg}=${EMPTY}
   ${actual_value}=   Json Search String   ${json}   ${jmes_path}
   ${actual_value}=   Set Variable If   $actual_value == '' and $expected_value == 'not_defined'   not_defined   ${actual_value}
   ${actual_value}=   normalize escapes spaces    text=${actual_value}
   ${expected_value}=   normalize escapes spaces    text=${expected_value}
   Should Be Equal As Strings   ${expected_value}   ${actual_value}   msg=${msg} expected: '${expected_value}' and got: '${actual_value}'

{% if sdwan.feature_profiles is defined and sdwan.feature_profiles.system_profiles is defined %}
{% set profile_banner_list = [] %}
{% for profile in sdwan.feature_profiles.system_profiles %}
 {% if profile.banner is defined %}
  {% set _ = profile_banner_list.append(profile.name) %}
 {% endif %}
{% endfor %}

{% if profile_banner_list != [] %}

*** Test Cases ***
Get System Profiles
    ${r}=    GET On Session With Retry    sdwan_manager    /dataservice/v1/feature-profile/sdwan/system
    Set Suite Variable    ${r}

{% for profile in sdwan.feature_profiles.system_profiles | default([]) %}
{% if profile.banner is defined %}

Verify Feature Profiles System Profiles {{ profile.name }} Banner Feature {{ profile.banner.name | default(defaults.sdwan.feature_profiles.system_profiles.banner.name) }}
    ${profile}=    Json Search    ${r.json()}    [?profileName=='{{ profile.name }}'] | [0]
    Run Keyword If    $profile is None    Fail    Feature Profile '{{ profile.name }}' should be present on the Manager
    ${profile_id}=    Json Search String    ${profile}    profileId
    ${system_banner_res}=    GET On Session With Retry    sdwan_manager    /dataservice/v1/feature-profile/sdwan/system/${profile_id}/banner
    ${system_banner}=    Json Search    ${system_banner_res.json()}    data[0].payload
    Run Keyword If    $system_banner is None    Fail    Feature '{{ profile.banner.name | default(defaults.sdwan.feature_profiles.system_profiles.banner.name) }}' expected to be configured within the system profile '{{ profile.name }}' on the Manager
    Set Suite Variable    ${system_banner}

    Should Be Equal Value Json String    ${system_banner}    name    {{ profile.banner.name | default(defaults.sdwan.feature_profiles.system_profiles.banner.name) }}    msg=name
    Should Be Equal Value Json Special_String    ${system_banner}    description    {{ profile.banner.description | default('not_defined') | normalize_special_string }}    msg=description

    {% if profile.banner.login is defined %}
        Should Be Equal Value Json Special_String    ${system_banner}    data.login.value    {{ profile.banner.login | default("not_defined") | normalize_special_string }}    msg=login
    {% else %}
        Should Be Equal Value Json Yaml    ${system_banner}    data.login    {{ profile.banner.login | default('not_defined') }}    {{ profile.banner.login_variable | default('not_defined') }}    msg=login
    {% endif %}

    
    {% if profile.banner.motd is defined %}
        Should Be Equal Value Json Special_String    ${system_banner}    data.motd.value    {{ profile.banner.motd | default("not_defined") | normalize_special_string }}    msg=motd
    {% else %}
        Should Be Equal Value Json Yaml    ${system_banner}    data.motd    {{ profile.banner.motd | default('not_defined') }}    {{ profile.banner.motd_variable | default('not_defined') }}    msg=motd
    {% endif %}


{% endif %}
{% endfor %}

{% endif %}

{% endif %}