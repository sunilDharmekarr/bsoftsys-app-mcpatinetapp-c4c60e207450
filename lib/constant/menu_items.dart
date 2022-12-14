import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/model/menu_model.dart';

final List<MenuModel> menus = [
  MenuModel(
      title: 'Appointment & Orders',
      icons: AppAssets.transaction,
      menuClick: 1,
      itemType: 'menu'),
  /* MenuModel(title: 'My Transaction',icons: AppIcons.transaction,menuClick: 1,itemType: 'menu'),*/
  MenuModel(
      title: 'My Wallet',
      icons: AppAssets.my_wallet,
      menuClick: 2,
      itemType: 'menu'),
  MenuModel(
      title: 'About Mumbai Clinic',
      icons: AppAssets.about_Mumbai_clinic,
      menuClick: 3,
      itemType: 'menu'),
  MenuModel(
      title: 'Terms & Condition',
      icons: AppAssets.terms_and_conditions,
      menuClick: 4,
      itemType: 'menu'),
  MenuModel(
      title: 'Privacy Policy',
      icons: AppAssets.privacy_policy,
      menuClick: 5,
      itemType: 'menu'),
  MenuModel(
      title: 'Help & Support',
      icons: AppAssets.help_support,
      menuClick: 6,
      itemType: 'menu'),
  MenuModel(
      title: 'Setting',
      icons: AppAssets.settings,
      menuClick: 7,
      itemType: 'menu'),
  MenuModel(
      title: 'Logout',
      icons: AppAssets.log_out,
      menuClick: 8,
      itemType: 'menu'),
];
