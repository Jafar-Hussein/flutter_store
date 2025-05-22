import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      unselectedLabelStyle: GoogleFonts.roboto(),
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'Hem'),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 30),
          label: 'Profil',
        ),
      ],
    );
  }
}

class CustomTitleNavBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomTitleNavBar({super.key});

  @override
  State<CustomTitleNavBar> createState() => _CustomTitleNavBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 19);
}

class _CustomTitleNavBarState extends State<CustomTitleNavBar> {
  final SearchController _searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 4,
      centerTitle: true,
      title: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Theme(
            data: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black,
              cardColor: Colors.grey[900],
              listTileTheme: const ListTileThemeData(
                textColor: Colors.white,
                iconColor: Colors.white,
              ),
            ),
            child: SearchAnchor(
              searchController: _searchController,
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  constraints: const BoxConstraints(
                    maxHeight: 36,
                    minHeight: 30,
                  ),
                  backgroundColor: MaterialStatePropertyAll(Colors.grey[850]),
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  ),
                  leading: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                  hintText: 'Sök...',
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  hintStyle: const WidgetStatePropertyAll(
                    TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  onTap: controller.openView,
                  onChanged: (_) => controller.openView(),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                    return List.generate(5, (index) {
                      final item = 'Förslag $index';
                      return ListTile(
                        title: Text(item),
                        onTap: () => controller.closeView(item),
                      );
                    });
                  },
            ),
          ),
        ),
      ),
    );
  }
}
