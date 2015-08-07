# Meteor TrueVault-Auth

TrueVault User Management and Authentication Support for Meteor

## Install

```bash
> meteor add emdagon:truevault-auth
```

## Usage

On client
```javascript
var tv = new TrueVault(truevaultAccountId);
tv.login('user', 'password'); // returns a jqXHR object
```

On server
```javascript
// all functions use HTTP synchronous calls
var tv = new TrueVault(truevaultAPIKey, TruevaultVaultId);
tv.getUser(userId [, getFullData]);
tv.createUser(username, password [, attributes]);
tv.updateUser(userId [, password, attributes, username]);
tv.searchUser(email);
tv.setUserAttributes(tokenOrKey, attributes [, documentId]);
tv.createUserGroup(userId, attributesDocumentId);
```

## License & Disclaimer

This package is released under the [MIT license](https://en.wikipedia.org/wiki/MIT_License). It's not officially supported by (and the author is not affiliated with) TrueVault.

Issues and PRs are welcomed!

Developed on [µBiome](http://ubiome.com/)'s time.
