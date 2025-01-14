import 'package:mapiah/src/elements/th_multilinecomment.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';
import 'package:test/test.dart';

import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/elements/th_element.dart';

import 'th_test_aux.dart';

void main() {
  group('initial', () {
    final file = THFile();

    test("THFile", () {
      expect(file.mapiahID, 0);
      expect(file.elements.length, 0);
    });
  });

  group('line breaks', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    var successes = [
      {
        'file': 'th_file_parser-00000-line_breaks.th2',
        'countElements': 3,
        'asFile': """encoding UTF-8
scrap poco_surubim_SCP01
endscrap
""",
      },
      {
        'file': 'th_file_parser-00001-no_linebreak_at_file_end.th2',
        'countElements': 3,
        'asFile': """encoding UTF-8
scrap poco_surubim_SCP01
endscrap
""",
      },
      {
        'file': 'th_file_parser-00002-backslash_ending.th2',
        'countElements': 3,
        'asFile': """encoding UTF-8
scrap poco_surubim_SCP01
endscrap
""",
      },
      {
        'file': 'th_file_parser-00003-long_line_indentation.th2',
        'countElements': 4,
        'asFile': r"""encoding UTF-8
scrap poco_surubim_SCP01
  point 2374 -482 station:fixed -visibility off -name \
      E15@final_de_semana_31_de_julho_de_2016
endscrap
""",
      },
    ];

    for (var success in successes) {
      test(success['file'], () async {
        final (file, isSuccessful, errors) =
            await parser.parse(THTestAux.testPath(success['file'] as String));
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.countElements(), success['countElements']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('xtherion config', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    var successes = [
      {
        'file': 'th_file_parser-00020-xtherionsetting_only.th2',
        'countElements': 2,
        'asFile': """encoding UTF-8
##XTHERION## xth_me_area_adjust -164 -2396 4206 1508
""",
      },
      {
        'file': 'th_file_parser-00035-xtherionimagesetting_only.th2',
        'countElements': 2,
        'asFile': """encoding UTF-8
##XTHERION## xth_me_image_insert {-36 1 1.0} {28 {}} croquis/croqui-007.jpg 0 {}
""",
      },
      {
        'file': 'th_file_parser-00040-adding_several_xtherionsettings.th2',
        'countElements': 5,
        'asFile': """encoding UTF-8
##XTHERION## xth_me_area_adjust -164 -2396 4206 1508
##XTHERION## xth_me_area_zoom_to 100
##XTHERION## xth_me_image_insert {1890 1 1.0} {1380 {}} croquis/croqui-006.jpg 0 {}
##XTHERION## xth_me_image_insert {-36 1 1.0} {28 {}} croquis/croqui-007.jpg 0 {}
""",
      },
    ];

    for (var success in successes) {
      test(success['file'], () async {
        final (file, isSuccessful, errors) =
            await parser.parse(THTestAux.testPath(success['file'] as String));
        expect(isSuccessful, true);
        expect(file, isA<THFile>());
        expect(file.countElements(), success['countElements']);

        final asFile = writer.serialize(file);
        expect(asFile, success['asFile']);
      });
    }
  });

  group('delete elements', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    var success = {
      'file': 'th_file_parser-02300-delete_elements.th2',
      'countElements': 26,
      'asFile': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 meter ]
  point 42.1 -5448.8 guano -visibility off -id P1
  comment

Another comment block.

But this one is inside a scrap!

This line below is not a scrap, it's a comment.
scrap test
endscrap

And this one also
scrap test2

  endcomment
  point 322.4 431.7 station -name A1
endscrap
""",
      'asFile2': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 meter ]
  comment

Another comment block.

But this one is inside a scrap!

This line below is not a scrap, it's a comment.
scrap test
endscrap

And this one also
scrap test2

  endcomment
  point 322.4 431.7 station -name A1
endscrap
""",
      'asFile3': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 meter ]
  point 322.4 431.7 station -name A1
endscrap
""",
      'asFile4': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment
""",
    };

    test("${success['file']} in parts", () async {
      final (file, isSuccessful, errors) =
          await parser.parse(THTestAux.testPath(success['file'] as String));
      expect(isSuccessful, true);
      expect(file, isA<THFile>());
      expect(file.countElements(), success['countElements']);

      var asFile = writer.serialize(file);
      expect(asFile, success['asFile']);

      expect(file.hasElementByTHID('poco_surubim_SCP01'), true);
      expect(file.hasElementByTHID('test'), false);

      final pointStation = file.elementByMapiahID(25);
      expect(pointStation, isA<THPoint>());
      expect((pointStation as THPoint).plaType, 'station');

      final pointGuano = file.elementByTHID('P1');
      expect(pointGuano, isA<THPoint>());
      expect((pointGuano as THPoint).plaType, 'guano');

      var countDeletedElements = 1;
      pointGuano.delete();
      expect(file.countElements(),
          (success['countElements'] as int) - countDeletedElements);
      asFile = writer.serialize(file);
      expect(asFile, success['asFile2']);

      final multilineComment = file.elementByMapiahID(10);
      expect(multilineComment, isA<THMultiLineComment>());

      countDeletedElements +=
          (multilineComment as THMultiLineComment).childrenMapiahID.length + 1;
      multilineComment.delete();
      expect(file.countElements(),
          (success['countElements'] as int) - countDeletedElements);
      asFile = writer.serialize(file);
      expect(asFile, success['asFile3']);

      var scrap = file.elementByTHID('poco_surubim_SCP01');
      countDeletedElements += (scrap as THScrap).childrenMapiahID.length + 1;
      file.deleteElementByTHID('poco_surubim_SCP01');
      expect(file.countElements(),
          (success['countElements'] as int) - countDeletedElements);

      file.delete();
      expect(file.countElements(), 0);
    });

    test("${success['file']} as once", () async {
      final (file, isSuccessful, errors) =
          await parser.parse(THTestAux.testPath(success['file'] as String));
      expect(isSuccessful, true);
      expect(file, isA<THFile>());
      expect(file.countElements(), success['countElements']);

      var asFile = writer.serialize(file);
      expect(asFile, success['asFile']);

      file.delete();
      expect(file.countElements(), 0);
    });
  });

  group('keep empty lines', () {
    final parser = THFileParser();
    final writer = THFileWriter();

    var success = {
      'file': 'th_file_parser-02300-delete_elements.th2',
      'countElements': 26,
      'asFile': r"""encoding UTF-8
comment
The scrap below is really complex.
Take care!!
endcomment

scrap poco_surubim_SCP01 -scale [ -164 -2396 3308 -2396 0 0 88.1888 0 meter ]
  point 42.1 -5448.8 guano -visibility off -id P1

  comment

Another comment block.

But this one is inside a scrap!

This line below is not a scrap, it's a comment.
scrap test
endscrap

And this one also
scrap test2

  endcomment

  point 322.4 431.7 station -name A1
endscrap
""",
    };

    test("${success['file']} as once", () async {
      final (file, isSuccessful, errors) =
          await parser.parse(THTestAux.testPath(success['file'] as String));
      expect(isSuccessful, true);
      expect(file, isA<THFile>());
      expect(file.countElements(), success['countElements']);

      var asFile = writer.serialize(file, includeEmptyLines: true);
      expect(asFile, success['asFile']);
    });
  });
}
