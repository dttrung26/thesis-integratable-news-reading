import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../common/constants.dart';

/// Server config
const serverConfig = {
  "url": "http://news.inspireui.com",
  "forgetPassword": "http://news.inspireui.com/wp-login.php?action=lostpassword"
};

const kOneSignalKey = {
  'appID': "a76dd222-35a3-4391-98db-9fadfb653304",
};

const CategoriesListLayout = kCategoriesLayout.card;

var kLayoutWeb = false;

const CategoryStaticImages = {
  30: 'https://images.unsplash.com/photo-1448131063153-f1e240f98a72?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  41: 'https://images.unsplash.com/photo-1496318447583-f524534e9ce1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  45: 'https://images.unsplash.com/photo-1558920558-fb0345e52561?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  46: 'https://images.unsplash.com/photo-1575301579296-39d50573daf5?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80',
  40: 'https://images.unsplash.com/photo-1467453678174-768ec283a940?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  37: 'https://images.unsplash.com/photo-1505678261036-a3fcc5e884ee?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  31: 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  36: 'https://images.unsplash.com/photo-1555196301-9acc011dfde4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  32: 'https://images.unsplash.com/photo-1517614138969-67d1892d0edf?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  33: 'https://images.unsplash.com/photo-1532301791573-4e6ce86a085f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60',
  34: 'https://images.unsplash.com/photo-1494919997560-caff2f1cff75?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1033&q=80',
};

/// the welcome screen data
List onBoardingData = [
  {
    "title": "Welcome to IU CSE Thesis",
    "image": "assets/images/fogg-delivery-1.png",
    "desc": "This is on-boarding screen 1"
  },
  {
    "title": "Connecting Surrounding World",
    "image": "assets/images/fogg-uploading-1.png",
    "desc": "This is on-boarding screen 2"
  },
  {
    "title": "Let's Get Started",
    "image": "fogg-order-completed.png",
    "desc": "This is on-boarding screen 3"
  },
];

/// Below config is use for further WooCommerce integration,
/// you can skip the config if not using WooCommerce
const afterShip = {
  "api": "e2e9bae8-ee39-46a9-a084-781d0139274f",
  "tracking_url": "https://fluxstore.aftership.com"
};

const Payments = {
  "paypal": "assets/icons/payment/paypal.png",
  "stripe": "assets/icons/payment/stripe.png",
  "razorpay": "assets/icons/payment/razorpay.png",
};

/// The product variant config
const ProductVariantLayout = {
  "color": "color",
  "size": "box",
  "height": "option",
};

const kAdvanceConfig = {
  "DefaultLanguage": "en",
  "IsRequiredLogin": false,
  "GuestCheckout": true,
  "EnableShipping": false,
  "GridCount": 3,
  "DetailedBlogLayout": kBlogLayout.fullSizeImageType,
  "EnablePointReward": false,
  "HeartButtonType": kHeartButtonType.cornerType,
  "DefaultPhoneISOCode": "+84"
};

/// The Google API Key to support Pick up the Address automatically
/// We recommend to generate both ios and android to restrict by bundle app id
/// The download package is remove these keys, please use your own key
const kGoogleAPIKey = {
  "android": "your-google-api-key",
  "ios": "your-google-api-key"
};

/// use to config the product image height for the product detail
/// height=(percent * width-screen)
/// isHero: support hero animate
const kProductDetail = {
  "height": 0.5,
  "marginTop": 0,
  "isHero": true,
  "safeArea": false,
  "showVideo": true,
  "showThumbnailAtLeast": 3
};

/// config for the chat app
const smartChat = [
  {
    'app': 'whatsapp://send?phone=84327433006',
    'iconData': FontAwesomeIcons.whatsapp
  },
  {'app': 'tel:8499999999', 'iconData': FontAwesomeIcons.phone},
  {'app': 'sms://8499999999', 'iconData': FontAwesomeIcons.sms},
  {'app': 'intercome', 'iconData': FontAwesomeIcons.intercom},
];
const String adminEmail = "tientien@gmail.com";

const kIntercomAPIKey = {
  'android': 'android_sdk-2c16c0e017a1e7b8d3b73b5a13a56b54cbf535c0',
  'ios': 'ios_sdk-33135e6653b055cec773b7903baff10efee94bc0',
  'appID': 'xro9xnfd'
};

const kAdConfig = {
  "type": kAdType.facebookNative,
  // ----------------- Facebook Ads  -------------- //

  "hasdedIdTestingDevice": "3f06ede0-3b68-4cdb-a639-1b1007cedd31",
  "bannerPlacementId": "430258564493822_489007588618919",
  "interstitialPlacementId": "430258564493822_489092398610438",
  "nativePlacementId": "430258564493822_489092738610404",
  "nativeBannerPlacementId": "430258564493822_489092925277052",

  // ------------------ Google Admob  -------------- //

  "androidAppId": "ca-app-pub-2101182411274198~7554000316",
  "androidUnitBanner": "ca-app-pub-2101182411274198/2054261627",
  "androidUnitInterstitial": "ca-app-pub-2101182411274198/7197727340",
  "androidUnitReward": "ca-app-pub-2101182411274198/5498660536",
  "iosAppId": "ca-app-pub-2101182411274198~6923444927",
  "iosUnitBanner": "ca-app-pub-2101182411274198/5418791562",
  "iosUnitInterstitial": "ca-app-pub-2101182411274198/9218413691",
  "iosUnitReward": "ca-app-pub-2101182411274198/9026842008",
  "waitingTimeToDisplayInterstitial": 10,
  "waitingTimeToDisplayReward": 10,
};
