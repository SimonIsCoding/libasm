;int strcmp(const char *s1, const char *s2);

;strncmp() is designed for comparing
     strings rather than binary data,
     characters that appear after a ‘\0’
     character are not compared.

	 ;The strcmp() and strncmp() functions
     return an integer greater than, equal
     to, or less than 0, according as the
     string s1 is greater than, equal to,
     or less than the string s2.  The
     comparison is done using unsigned
     characters, so that ‘\200’ is greater
     than ‘\0’.