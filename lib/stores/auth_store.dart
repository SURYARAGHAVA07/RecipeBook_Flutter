import 'package:mobx/mobx.dart';
import '../services/storage_service.dart';

class AuthStore {
  final StorageService storage;

  // Observables
  final Observable<bool> loggedIn = Observable(false);
  final Observable<String?> userName = Observable(null);
  final Observable<String?> userEmail = Observable(null);

  AuthStore(this.storage) {
    // initialize from storage on creation
    init();
  }

  void init() {
    final u = storage.getUser();
    runInAction(() {
      if (u != null) {
        loggedIn.value = true;
        userName.value = u['name'];
        userEmail.value = u['email'];
      } else {
        loggedIn.value = false;
        userName.value = null;
        userEmail.value = null;
      }
    });
  }

  /// Mock login: store name+email and set loggedIn true
  void login(String email, String name) {
    storage.saveUser(name, email);
    runInAction(() {
      loggedIn.value = true;
      userName.value = name;
      userEmail.value = email;
    });
  }

  /// Mock register: same behavior as login for this demo
  void register(String name, String email) {
    storage.saveUser(name, email);
    runInAction(() {
      loggedIn.value = true;
      userName.value = name;
      userEmail.value = email;
    });
  }

  void logout() {
    storage.clearUser();
    runInAction(() {
      loggedIn.value = false;
      userName.value = null;
      userEmail.value = null;
    });
  }
}
