import re

class Filter:
    name = "normalize_special_string"

    @classmethod
    def filter(cls, text):
        """
        JINJA Filter to 
        1) escape consecutive 2 spaces in the text with native Robot escaping syntax.
        2) escape special characters like \n, \t, \r for Robot Framework.
        3) double every trailing backslash, which Robot Framework would otherwise halve or drop.
        """
        try:
            text = text.replace("  ","${SPACE}${SPACE}").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")
        except AttributeError:
            return text
        # Robot turns "\\" into "\" and drops a lone trailing backslash, so double the whole trailing run
        trailing = len(text) - len(text.rstrip("\\"))
        return text + "\\" * trailing