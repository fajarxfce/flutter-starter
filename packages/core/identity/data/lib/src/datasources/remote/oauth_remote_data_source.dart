import 'package:identity_data/src/config/oauth_configuration.dart';
import 'package:identity_data/src/datasources/remote/auth_api.dart';
import 'package:identity_data/src/oauth/oauth_attempt.dart';
import 'package:identity_data/src/oauth/oauth_browser.dart';
import 'package:identity_data/src/responses/login_response.dart';
import 'package:identity_domain/identity_domain.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
final class OAuthRemoteDataSource {
  OAuthRemoteDataSource(this._api, this._browser, this._configuration);

  final AuthApi _api;
  final OAuthBrowser _browser;
  final OAuthConfiguration _configuration;

  Set<IdentityProvider> get providers => _configuration.providers;

  Future<LoginResponse> login(IdentityProvider provider) async {
    final attempt = OAuthAttempt(redirectUri: _configuration.redirectUri!);
    final callback = await _browser.authenticate(
      attempt.authorizationUri(_configuration.apiOrigin, provider),
      attempt.redirectUri,
    );
    final request = attempt.exchangeRequest(Uri.parse(callback));
    return await _api.exchangeOAuth(provider.name, request);
  }
}
