import 'package:mumbaiclinic/constant/app_assets.dart';

class BannerModel{
  String image;
  String  header;
  String  header1;
  String message;
  String bg;

  BannerModel(this.image, this.bg,this.header,this.header1,this.message);

  static List<BannerModel> getBanners(){
    return [
      BannerModel(AppAssets.one,AppAssets.one_bg,
        'Easy Access to','best Doctor:',
        'We\’ve formed a team of leading specialists who are best in their fields and committed to providing you with the most appropriate treatments.',),

      BannerModel(AppAssets.two,AppAssets.two_bg,
          'Easy Diagnostic Tests and   ',"Auto storage of Results",
          'Ease of quickly ordering tests.Result will be available automatically in your app (EMR)'),

      BannerModel(AppAssets.three,AppAssets.three_bg,
          'Preventive Health care :','Live longer live healthier!!:',
          'We closely monitor your health recorded and follow the latest guidelines in healthcare in order to prevent health problems.'),
    ];
  }
}