# you_and_i

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Allowing TLS against IP endpoints

If your matching server uses a TLS certificate issued for a hostname instead of the raw IP address, the client can skip
hostname validation for specific hosts by setting `INSECURE_SSL_HOSTS` to a comma-separated list of allowed hostnames or IP
addresses. This is primarily intended for controlled environments where a trusted certificate cannot be reissued.
