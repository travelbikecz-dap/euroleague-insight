import 'package:flutter_test/flutter_test.dart';
import 'package:euroliga_predictor/services/recent_form_service.dart';

void main() {
  group('RecentFormService', () {
    test('selects RS games ordered by gameday then date', () {
      const xml = '''
<results>
  <game>
    <round>RS</round><gameday>1</gameday><date>Oct 3, 2025</date>
    <gamenumber>1</gamenumber><gamecode>E2025_1</gamecode>
    <hometeam>TEAM A</hometeam><homecode>AAA</homecode><homescore>80</homescore>
    <awayteam>TEAM B</awayteam><awaycode>BBB</awaycode><awayscore>70</awayscore>
    <played>true</played>
  </game>
  <game>
    <round>RS</round><gameday>2</gameday><date>Oct 10, 2025</date>
    <gamenumber>2</gamenumber><gamecode>E2025_2</gamecode>
    <hometeam>TEAM B</hometeam><homecode>BBB</homecode><homescore>80</homescore>
    <awayteam>TEAM A</awayteam><awaycode>AAA</awaycode><awayscore>75</awayscore>
    <played>true</played>
  </game>
  <game>
    <round>PO</round><gameday>3</gameday><date>May 1, 2026</date>
    <gamenumber>3</gamenumber><gamecode>E2025_3</gamecode>
    <hometeam>TEAM A</hometeam><homecode>AAA</homecode><homescore>90</homescore>
    <awayteam>TEAM B</awayteam><awaycode>BBB</awaycode><awayscore>88</awayscore>
    <played>true</played>
  </game>
</results>
''';

      final result = RecentFormService.computeFromResultsXml(xml);

      expect(result.formByClubCode['AAA'], ['W', 'L']);
      expect(result.formByClubCode['BBB'], ['L', 'W']);
      expect(result.gamesByClubCode['AAA']?.last.gameday, 2);
    });

    test('postponed game on later date stays within same gameday order', () {
      const xml = '''
<results>
  <game>
    <round>RS</round><gameday>38</gameday><date>Apr 16, 2026</date>
    <gamenumber>10</gamenumber><gamecode>E2025_10</gamecode>
    <hometeam>TEAM A</hometeam><homecode>AAA</homecode><homescore>70</homescore>
    <awayteam>TEAM B</awayteam><awaycode>BBB</awaycode><awayscore>80</awayscore>
    <played>true</played>
  </game>
  <game>
    <round>RS</round><gameday>37</gameday><date>Apr 10, 2026</date>
    <gamenumber>9</gamenumber><gamecode>E2025_9</gamecode>
    <hometeam>TEAM A</hometeam><homecode>AAA</homecode><homescore>85</homescore>
    <awayteam>TEAM C</awayteam><awaycode>CCC</awaycode><awayscore>80</awayscore>
    <played>true</played>
  </game>
  <game>
    <round>RS</round><gameday>38</gameday><date>Apr 17, 2026</date>
    <gamenumber>11</gamenumber><gamecode>E2025_11</gamecode>
    <hometeam>TEAM C</hometeam><homecode>CCC</homecode><homescore>90</homescore>
    <awayteam>TEAM B</awayteam><awaycode>BBB</awaycode><awayscore>88</awayscore>
    <played>true</played>
  </game>
</results>
''';

      final result = RecentFormService.computeFromResultsXml(xml);

      expect(result.formByClubCode['AAA']?.last, 'L');
      expect(result.formByClubCode['BBB']?.last, 'L');
      expect(result.formByClubCode['CCC']?.last, 'W');
    });
  });
}
