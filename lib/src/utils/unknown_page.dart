import '../nav_page.dart';
import 'page_not_found_widget.dart';

class UnknownPage extends NavPage {
  UnknownPage()
      : super(
          pattern: '/404',
          name: 'Page Not Found',
          builder: () => const PageNotFoundWidget(),
        );
}
