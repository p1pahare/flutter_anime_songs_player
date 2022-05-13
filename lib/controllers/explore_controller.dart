import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/democat.dart';
import 'package:anime_themes_player/repositories/network_calls.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ExploreController extends GetxController with StateMixin<List<DemoCat>> {
  NetworkCalls networkCalls = NetworkCalls();

  bringCats() async {
    change([], status: RxStatus.loading());
    ApiResponse apiResponse = await networkCalls.getCats();
    if (apiResponse.status) {
      List<DemoCat> cats = (apiResponse.data as List<dynamic>)
          .map((e) => DemoCat.fromJson(e))
          .toList();
      if (cats.isEmpty) {
        change(cats, status: RxStatus.empty());
      }
      change(cats, status: RxStatus.success());
    } else {
      change(null, status: RxStatus.error(apiResponse.message));
    }
  }
}
