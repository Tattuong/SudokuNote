import 'package:flutter_test/flutter_test.dart';
import 'package:sudokunote/core/constants/iap_constants.dart';
import 'package:sudokunote/core/services/iap_config_service.dart';
import 'package:sudokunote/models/shop_item.dart';

void main() {
  test('SudokuNote IAP ids and N288 endpoint', () {
    expect(IapConstants.productPrefix, 'sn');
    expect(IapConstants.remoteConfigUrl, 'https://api2.blwsmartware.net/N288.json');
    expect(IapConstants.coinPackIds.first, 'sn_pack_1');
    expect(IapConstants.coinPackIds.last, 'sn_pack_10');
    expect(IapConstants.coinPackIds, hasLength(10));
    expect(IapConstants.removeAdsProductId, 'sn_remove_ads');
    expect(IapConstants.proProductId, 'sn_pro');
    expect(IapConstants.allProductIds, containsAll([...IapConstants.coinPackIds, 'sn_remove_ads', 'sn_pro']));
    expect(IapConstants.coinsForProduct('sn_pack_5'), 500);
    expect(IapConstants.freeArchiveLimit, 8);
    expect(IapConstants.proArchiveLimit, 99);
  });

  test('disable=1 hides billing only', () {
    final off = IapRemoteConfig.fromJson({'disable': 1, 'name': 'SudokuNote'});
    expect(off.billingDisabled, isTrue);
    final on = IapRemoteConfig.fromJson({'disable': 0, 'name': 'SudokuNote', 'code': 'FULL_IAP'});
    expect(on.billingDisabled, isFalse);
    expect(on.name, 'SudokuNote');
  });

  test('shop catalog extras can be applied and reverted', () {
    expect(ShopCatalog.items.where((e) => e.id.startsWith('theme_')), isNotEmpty);
    expect(ShopCatalog.find(ShopCatalog.featPro), isNotNull);
    expect(ShopCatalog.find('remove_ads'), isNotNull);
    expect(ShopCatalog.find(ShopCatalog.featHint), isNotNull);
    expect(ShopCatalog.find(ShopCatalog.featSound), isNotNull);
    expect(ShopCatalog.isDefaultId(ShopCatalog.defaultThemeId), isTrue);
  });
}
