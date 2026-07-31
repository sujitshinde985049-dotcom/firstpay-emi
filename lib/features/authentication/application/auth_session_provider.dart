import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionState {
  const AuthSessionState._({required this.isAuthenticated, this.email});

  const AuthSessionState.authenticated(String? email)
    : this._(isAuthenticated: true, email: email);

  const AuthSessionState.unauthenticated() : this._(isAuthenticated: false);

  final bool isAuthenticated;
  final String? email;
}

final authSessionProvider = StreamProvider<AuthSessionState>((ref) async* {
  try {
    final auth = Supabase.instance.client.auth;
    yield _stateFor(auth.currentSession);
    await for (final event in auth.onAuthStateChange) {
      yield _stateFor(event.session);
    }
  } on Object {
    yield const AuthSessionState.unauthenticated();
  }
});

AuthSessionState _stateFor(Session? session) => session == null
    ? const AuthSessionState.unauthenticated()
    : AuthSessionState.authenticated(session.user.email);
