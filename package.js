Package.describe({
  name: 'emdagon:truevault-auth',
  version: '0.0.1',
  summary: 'TrueVault User Management and Authentication Support for Meteor',
  git: 'https://github.com/emdagon/meteor-truevault-auth.git',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');

  api.use('coffeescript', ['client', 'server']);
  api.use(['underscore', 'http'], 'server');
  api.use('jquery', 'client');

  api.addFiles('client.coffee', 'client');
  api.addFiles('server.coffee', 'server');

  api.export('TrueVault');
});
