import 'package:dart_numerics/dart_numerics.dart' as numerics;

/// Constants and others definitioons that should be generally available.

const String thDebugPath =
    '/home/rodrigo/devel/mapiah/test/auxiliary/unused/th2parser';

const String thCommentChar = '#';
const String thDecimalSeparator = '.';
const String thBackslash = '\\';
const String thUnixLineBreak = '\n';
const String thWindowsLineBreak = '\r\n';
const String thDoubleQuote = '"';
const String thDoubleQuotePair = r'""';

/// This char is from the private-use chars.
// See [https://www.unicode.org/faq/private_use.html]
const String thDoubleQuotePairEncoded = '\uE001';
const String thWhitespaceChars = ' \t';

const String thIndentation = '  ';

const int thMaxEncodingLength = 20;
const int thMaxFileLineLength = 80;
const int thMaxDecimalPositions = 6;

const String thDefaultEncoding = 'UTF-8';

const String thNullValueAsString = '!!! property has null value !!!';

const double thCanvasVisibleMargin = 0.1;
const double thCanvasOutOfSightMargin = 2.0;

const double thZoomFactor = numerics.sqrt2;
const double thMinimumSizeForDrawing = 10.0;

const int thFirstMapiahIDForTHFiles = -1;
const int thFirstMapiahIDForElements = 1;

const int thDecimalPositionsForOffsetMapper = 7;

const String thDefaultLengthUnit = 'm';
const String thMultipleChoiceCommandOptionID = 'multiplechoice|';

const String thAreaBorderTHIDID = 'thareaborderthid';
const String thAreaID = 'tharea';
const String thBezierCurveLieSegmentID = 'thbeziercurvelinesegment';
const String thCommentID = 'thcomment';
const String thEmptyLineID = 'themptyline';
const String thEncodingID = 'thencoding';
const String thEndareaID = 'thendarea';
const String thEndcommentID = 'thendcomment';
const String thEndlineID = 'thendline';
const String thEndscrapID = 'thendscrap';
const String thLineID = 'thline';
const String thLineSegmentID = 'thlinesegment';
const String thMultilineCommentContentID = 'thmultilinecommentcontent';
const String thMultilineCommentID = 'thmultilinecomment';
const String thPointID = 'thpoint';
const String thScrapID = 'thscrap';
const String thStraightLineSegmentID = 'thstraightlinesegment';
const String thUnrecognizedCommandID = 'thunrecognizedcommand';
const String thXTherionConfigID = 'thxtherionconfig';

// keyword . a sequence of A-Z, a-z, 0-9 and _-/ characters (not starting with ‘-’).
final RegExp thKeywordRegex = RegExp(r'^[a-zA-Z0-9_][a-zA-Z0-9_-]*$');

// ext keyword . keyword that can also contain +*.,’ characters, but not on the first
// position.
final RegExp thExtKeywordRegex =
    RegExp(r'''^[a-zA-Z0-9_][a-zA-Z0-9_+*.,'-]*$''');

// date . a date (or a time interval) specification in the format
// YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]
// or ‘-’ to leave a date unspecified.
final RegExp thDatetimeRegex = RegExp(
    r'^(?<year>\d{4}(\.(?<month>(0[1-9]|1[0-2]))(\.(?<day>(0[1-9]|[12][0-9]|3[01]))(\@(?<hour>(0[0-9]|1[0-9]|2[0-4]))(\:(?<minute>(0[0-9]|[1-5][0-9]))(\:(?<second>(0[0-9]|[1-5][0-9]))(\.(?<fractional>(0[0-9]|[1-5][0-9])))?)?)?)?)?)?)$');

const String thConfigDirectory = 'Config';
const String thMainDirectory = 'Mapiah';
const String thProjectsDirectory = 'Projects';

const String thMainConfigFilename = 'mapiah.toml';
const String thDefaultLocaleID = 'sys';
const String thEnglishLocaleID = 'en';

const double thFloatingActionIconSize = 32;

const double thDefaultSelectionTolerance = 10.0;
const double thDefaultPointRadius = 5.0;
const double thDefaultLineThickness = 2.0;

const String thMainConfigSection = 'Main';
const String thMainConfigLocale = 'Locale';
const String thFileEditConfigSection = 'FileEdit';
const String thFileEditConfigSelectionTolerance = 'SelectionTolerance';
const String thFileEditConfigPointRadius = 'PointRadius';
const String thFileEditConfigLineThickness = 'LineThickness';
