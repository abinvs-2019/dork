import 'package:enumerators/enumerators.dart';
import 'package:test/test.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:dartz/dartz.dart';
import 'laws.dart';

void main() {

  test("demo", () {
    Option<int> stringToInt(String intString) => catching(() => int.parse(intString)).toOption();
    final IMap<int, String> intToEnglish = imap({1: "one", 2: "two", 3: "three"});
    final IMap<String, String> englishToSwedish = imap({"one": "ett", "two": "två"});
    Option<String> intStringToSwedish(String intString) => stringToInt(intString).bind(intToEnglish.get).bind(englishToSwedish.get);

    expect(intStringToSwedish("1"), some("ett"));
    expect(intStringToSwedish("2"), some("två"));
    expect(intStringToSwedish("siffra"), none());
    expect(intStringToSwedish("3"), none());
  });

  test("transformer demo", () {
    final Monad<List<Option>> M = optionTMonad(ListMP) as Monad<List<Option>>;
    final expected = [some("a!"), some("a!!"), none(), some("c!"), some("c!!")];
    expect(M.bind([some("a"), none(), some("c")], (e) => [some(e + "!"), some(e + "!!")]), expected);
  });

  test("sequencing", () {
    final IList<Option<int>> l = ilist([some(1), some(2)]);
    expect(l.sequence(OptionMP), some(ilist([1,2])));
    expect(l.sequence(OptionMP).sequence(IListMP), l);

    final IList<Option<int>> l2 = ilist([some(1), none(), some(2)]);
    expect(l2.sequence(OptionMP), none());
    expect(l2.sequence(OptionMP).sequence(IListMP), ilist([none()]));
  });

  group("OptionM", () => checkMonadLaws(OptionMP));

  group("OptionTMonad+Id", () => checkMonadLaws(optionTMonad(IdM)));

  group("OptionTMonad+IList", () => checkMonadLaws(optionTMonad(IListMP)));

  group("OptionM+Foldable", () => checkFoldableMonadLaws(OptionTr, OptionMP));

  group("OptionMi", () => checkMonoidLaws(new OptionMonoid(NumSumMi), c.ints.map(some)));

  final intOptions = c.ints.map((i) => i%2==0 ? some(i) : none()) as Enumeration<Option<int>>;

  group("OptionTr", () => checkTraversableLaws(OptionTr, intOptions));

  group("Option FoldableOps", () => checkFoldableOpsProperties(intOptions));

  test("iterable", () {
    expect(some(1).toIterable().toList(), [1]);
    expect(none().toIterable().toList(), []);
  });
}