import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_account_kit/flutter_account_kit.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localstorage/localstorage.dart';

import '../common/constants.dart';
import '../services/wordpress.dart';

class UserModel with ChangeNotifier {
  UserModel() {
    getUser();
  }

  WordPress _service = WordPress();
  User user;
  bool loggedIn = false;
  String message;
  bool loading = false;
  final _auth = FirebaseAuth.instance;

  /// Login by apple
  void loginApple(
      {String email, String fullName, Function success, Function fail}) async {
    try {
      user = await _service.loginApple(email: email, fullName: fullName);
      loggedIn = true;
      saveUser(user);
      success(user);

      notifyListeners();
    } catch (err) {
      fail();
    }
  }

  /// Login by Firebase phone
  void loginFirebaseSMS(
      {String phoneNumber, Function success, Function fail}) async {
    try {
      user = await _service.loginSMS(token: phoneNumber);
      loggedIn = true;
      saveUser(user);
      success(user);

      notifyListeners();
    } catch (err) {
      fail();
    }
  }

  void saveJwtAuthToken(String token) async {
    final LocalStorage storage = new LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey['jwtToken'], token);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<String> getJwtAuthToken() async {
    final LocalStorage storage = new LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if (ready) {
        return await storage.getItem(kLocalKey['jwtToken']);
      }
      return '';
    } catch (err, trace) {
      print(err);
      print(trace);
      return '';
    }
  }
//  void loginGoogle({Function success, Function fail}) async {
//    try {
//      GoogleSignIn _googleSignIn = GoogleSignIn(
//        scopes: [
//          'email',
//        ],
//      );
//      GoogleSignInAccount res = await _googleSignIn.signIn();
//      GoogleSignInAuthentication auth = await res.authentication;
//      user = await _service.loginGoogle(token: auth.accessToken);
//      loggedIn = true;
//      saveUser(user);
//      success(user);
//      notifyListeners();
//    } catch (err) {
//      print(err.toString());
//      fail(
//          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
//              err.toString());
//    }
//  }

  void loginGoogle({Function success, Function fail}) async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
        ],
      );
      GoogleSignInAccount res = await _googleSignIn.signIn();
      loggedIn = true;
      user = User.fromGoogle(res);
      saveUser(user);
      success(user);
      notifyListeners();
    } catch (err) {
      fail(
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString());
    }
  }

  /// Login by Facebook
  void loginFB({Function success, Function fail}) async {
    try {
      final FacebookLoginResult result =
          await FacebookLogin().logIn(['email', 'public_profile']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken accessToken = result.accessToken;
          AuthCredential credential = FacebookAuthProvider.getCredential(
              accessToken: accessToken.token);
          _auth.signInWithCredential(credential);
          user = await _service.loginFacebook(token: accessToken.token);

          loggedIn = true;

          print(user);
          saveUser(user);

          success(user);
          break;
        case FacebookLoginStatus.cancelledByUser:
          fail('The login is cancel');
          break;
        case FacebookLoginStatus.error:
          fail('Error: ${result.errorMessage}');
          break;
      }

      notifyListeners();
    } catch (err) {
      print(err.toString());
      fail(err.toString());
    }
  }

  /// Login by Facebook account kit
  void loginSMS({Function success, Function fail}) async {
    try {
      FlutterAccountKit akt = FlutterAccountKit();
      Config cfg = Config()
        ..responseType = ResponseType.token
        ..facebookNotificationsEnabled = true
        ..receiveSMS = true
        ..readPhoneStateEnabled = true;

      akt.configure(cfg);

      LoginResult result = await akt.logInWithPhone();
      print('account id ${result.accessToken.accountId}');

      if (result.status == LoginStatus.cancelledByUser) {
        fail('Login cancelled by user');
      } else if (result.status == LoginStatus.error) {
        fail('${result.errorMessage}');
      } else {
        user = await _service.loginSMS(token: result.accessToken.token);
        loggedIn = true;

        final String autoGeneratedFirebaseUserEmail = user.name + '@gmail.com';
        final String autoGeneratedFirebaseUserPassword = user.name + 'ps';
        _auth
            .createUserWithEmailAndPassword(
                email: autoGeneratedFirebaseUserEmail,
                password: autoGeneratedFirebaseUserPassword)
            .catchError((signInErr) {
          if (signInErr is PlatformException) {
            if (signInErr.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
              print("Phone number has been generated already, do login");
            }
          } else {
            print("Login with generated email from phone");
          }
        });
        _auth.signInWithEmailAndPassword(
            email: autoGeneratedFirebaseUserEmail,
            password: autoGeneratedFirebaseUserPassword);
        saveUser(user);
        success(user);

        notifyListeners();
      }
    } catch (err) {
      fail();
    }
  }

  void saveUser(User user) async {
    final LocalStorage storage = new LocalStorage("thesiscseiu");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["userInfo"], user);
      }
    } catch (err) {
      print(err);
    }
  }

  void getUser() async {
    final LocalStorage storage = new LocalStorage("thesiscseiu");
    try {
      final ready = await storage.ready;

      if (ready) {
        final json = storage.getItem(kLocalKey["userInfo"]);
        if (json != null) {
          user = User.fromLocalJson(json);
          loggedIn = true;
        }
      }
    } catch (err) {
      print(err);
    }
  }

  void createUser(
      {username,
      password,
      firstName,
      lastName,
      Function success,
      Function fail}) async {
    try {
      loading = true;
      notifyListeners();
      user = await _service.createUser(
        firstName: firstName,
        lastName: lastName,
        username: username,
        password: password,
      );
      loggedIn = true;
      saveUser(user);
      success(user);

      loading = false;
      notifyListeners();
    } catch (err) {
      fail(err.toString());
      loading = false;
      notifyListeners();
    }
  }

  void logout() async {
    user = null;
    loggedIn = false;
    final LocalStorage storage = new LocalStorage("thesiscseiu");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.deleteItem(kLocalKey["userInfo"]);
        await storage.deleteItem(kLocalKey["shippingAddress"]);
        await storage.deleteItem(kLocalKey["recentSearches"]);
        await storage.deleteItem(kLocalKey["wishlist"]);
      }
    } catch (err) {
      print(err);
    }
    notifyListeners();
  }

  void login({username, password, Function success, Function fail}) async {
    try {
      loading = true;
      notifyListeners();

      user = await _service.login(
        username: username,
        password: password,
      );

      loggedIn = true;
      saveUser(user);
      success(user);
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail(err.toString());
      print('login err $err');
      notifyListeners();
    }
  }
}

class User {
  dynamic id;
  bool loggedIn;
  String name;
  String firstName;
  String lastName;
  String username;
  String email;
  String password;
  String picture;
  String cookie;
  String role;
  // from WooCommerce Json
  User.fromJsonFB(Map<String, dynamic> json) {
    try {
      var user = json['user'];
      loggedIn = true;
      id = json['wp_user_id'];
      name = user['name'];
      username = user['user_login'];
      cookie = json['cookie'];
      firstName = user["first_name"];
      lastName = user["last_name"];
      email = user["email"];
      picture = user["picture"]['data']['url'] ?? '';
    } catch (e) {
      print(e.toString());
    }
  }

  User.fromGoogle(GoogleSignInAccount account) {
    id = account.id;
    name = account.displayName;
    email = account.email;
    picture = account.photoUrl;
  }

  User.fromFacebook(AuthResult account) {
    id = account.user.uid;
    name = account.user.displayName;
    email = account.user.email;
    picture = account.user.photoUrl;
  }

  // from WooCommerce Json
  User.fromJsonSMS(Map<String, dynamic> json) {
    try {
      var user = json['user'];
      loggedIn = true;
      id = json['wp_user_id'];
      name = json['user_login'];
      cookie = json['cookie'];
      username = user['id'];
      firstName = json['user_login'];
      lastName = '';
      email = user['id'];
    } catch (e) {
      print(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "loggedIn": loggedIn,
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "email": email,
      "password": password,
      "picture": picture,
      "cookie": cookie
    };
  }

  User.fromLocalJson(Map<String, dynamic> json) {
    try {
      loggedIn = json['loggedIn'];
      id = json['id'];
      name = json['name'];
      cookie = json['cookie'];
      username = json['username'];
      firstName = json['firstName'];
      lastName = json['lastName'];
      email = json['email'];
      password = json['password'];
      picture = json['picture'];
    } catch (e) {
      print(e.toString());
    }
  }

  // from Create User
  User.fromAuthUser(Map<String, dynamic> json, String _cookie) {
    try {
      cookie = _cookie;
      id = json['id'];
      name = json['displayname'];
      username = json['username'];
      firstName = json['firstname'];
      lastName = json['lastname'];
      email = json['email'];
      password = json['password'];
      picture = json['avatar'];
      role = json['role'][0];
      loggedIn = true;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  String toString() => 'User { username: $id $name $email}';
}

class UserPoints {
  int points;
  List<UserEvent> events = [];

  UserPoints.fromJson(Map<String, dynamic> json) {
    points = json['points_balance'];
    for (var event in json['events']) {
      events.add(UserEvent.fromJson(event));
    }
  }
}

class UserEvent {
  String id;
  String userId;
  String orderId;
  String date;
  String description;
  String points;

  UserEvent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    date = json['date_display_human'];
    description = json['description'];
    points = json['points'];
  }
}
