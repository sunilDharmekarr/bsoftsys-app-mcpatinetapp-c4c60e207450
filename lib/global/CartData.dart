import 'package:mumbaiclinic/model/LabTestModel.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class CartData {
  static List<Labtest> cartItems = [];

  static addItems(Labtest data) {
    if (cartItems.length == 0) {
      //Utils.showToast(message: 'Added In Cart.');
      cartItems.add(data);
    } else {
      if (cartItems.any((element) => (data.testId == null
          ? element.profileId == data.profileId
          : element.testId == data.testId))) {
        // Utils.showToast(message: 'Added In Cart.');
      } else {
        //Utils.showToast(message: 'Added In Cart.');
        cartItems.add(data);
      }
    }
    /* if(cartItems.any((element) => (data.testId==null?element.profileId!=data.profileId:element.testId!=data.testId))){
      Utils.showToast(message: 'Added In Cart.');
      cartItems.add(data);
    }else{

    }*/
  }

  static removeItems(Labtest data) {
    cartItems.remove(data);
  }

  static clearData() {
    cartItems.clear();
  }

  static List<Labtest> get getItems {
    return cartItems;
  }
}
