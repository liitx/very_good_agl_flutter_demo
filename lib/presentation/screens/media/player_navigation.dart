import 'package:flutter_ics_homescreen/core/utils/helpers.dart';
import 'package:flutter_ics_homescreen/export.dart';
import 'media_nav_notifier.dart';

class PlayerNavigation extends ConsumerStatefulWidget {
  const PlayerNavigation({super.key, required this.onPressed});
  final Function onPressed;

  @override
  ConsumerState<PlayerNavigation> createState() => _PlayerNavigationState();
}

class _PlayerNavigationState extends ConsumerState<PlayerNavigation> {
  List<String> navItems = ["My Media", "FM", "AM", "XM"];
  Map<MediaNavState, String> navStateMap = {
    MediaNavState.media: "My Media",
    MediaNavState.fm: "FM",
    MediaNavState.am: "AM",
    MediaNavState.xm: "XM"
  };

  @override
  Widget build(BuildContext context) {
    var navState = ref.watch(mediaNavStateProvider);
    var selectedNav = navStateMap[navState];

    return Row(
        children: navItems
            .map((e) => Expanded(
                    child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      selectedNav == e
                          ? AGLDemoColors.neonBlueColor
                          : AGLDemoColors.buttonFillEnabledColor,
                      AGLDemoColors.gradientBackgroundDarkColor
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    // color: selectedNav == e
                    //     ? AGLDemoColors.neonBlueColor
                    //     : AGLDemoColors.buttonFillEnabledColor,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (e == "My Media" || e == "FM") {
                          for (MapEntry<MediaNavState, String> me
                              in navStateMap.entries) {
                            if (me.value == e) widget.onPressed(me.key);
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                            border: Border(
                                left: selectedNav == e
                                    ? const BorderSide(color: Colors.white12)
                                    : BorderSide.none,
                                right: selectedNav == e
                                    ? const BorderSide(color: Colors.white12)
                                    : BorderSide.none,
                                top: BorderSide(
                                    color: selectedNav == e
                                        ? Colors.white
                                        : Colors.white24,
                                    width: selectedNav == e ? 2 : 1))),
                        child: Text(
                          e,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 26,
                              shadows: [
                                selectedNav == e
                                    ? Helpers.dropShadowRegular
                                    : Helpers.dropShadowBig
                              ],
                              color: selectedNav == e
                                  ? Colors.white
                                  : AGLDemoColors.periwinkleColor,
                              fontWeight: selectedNav == e
                                  ? FontWeight.w700
                                  : FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                )))
            .toList());
  }
}
