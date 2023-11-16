/// Constants and others definitioons that should be generally available.
const thCommentChar = '#';
const thDecimalSeparator = '.';
const thBackslash = '\\';
const thLineBreak = '\n';
const thDoubleQuote = '"';
const thDoubleQuotePair = r'""';

/// This char is from the private-use chars.
// See [https://www.unicode.org/faq/private_use.html]
const thDoubleQuotePairEncoded = '\uE001';
const thWhitespaceChars = ' \t';

const thIndentation = '  ';

const thMaxEncodingLength = 20;
const thMaxFileLineLength = 80;

const thDefaultEncoding = 'UTF-8';

const thNullValueAsString = '!!! property has null value !!!';

const thCanvasMargin = 0.1;

// keyword . a sequence of A-Z, a-z, 0-9 and _-/ characters (not starting with ‘-’).
final thKeywordRegex = RegExp(r'^[a-zA-Z0-9_][a-zA-Z0-9_-]*$');

// ext keyword . keyword that can also contain +*.,’ characters, but not on the first
// position.
final thExtKeywordRegex = RegExp(r'''^[a-zA-Z0-9_][a-zA-Z0-9_+*.,'-]*$''');

// date . a date (or a time interval) specification in the format
// YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]
// or ‘-’ to leave a date unspecified.
final thDatetimeRegex = RegExp(
    r'^(?<year>\d{4}(\.(?<month>(0[1-9]|1[0-2]))(\.(?<day>(0[1-9]|[12][0-9]|3[01]))(\@(?<hour>(0[0-9]|1[0-9]|2[0-4]))(\:(?<minute>(0[0-9]|[1-5][0-9]))(\:(?<second>(0[0-9]|[1-5][0-9]))(\.(?<fractional>(0[0-9]|[1-5][0-9])))?)?)?)?)?)?)$');
