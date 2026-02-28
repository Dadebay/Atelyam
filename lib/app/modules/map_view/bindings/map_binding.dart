import 'package:atelyam/app/modules/map_view/controllers/map_view_controller.dart';
import 'package:get/get.dart';

class MapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapViewController>(() => MapViewController());
  }
}
