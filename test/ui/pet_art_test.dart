import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/ui/pet_art.dart';

void main() {
  test('stage art keeps the adopted variant and growth stage', () {
    expect(
      PetArt.stage('pet_cat', PetStage.d, variantId: 'pet_cat_v4'),
      'assets/runtime/pets/cat/pet_cat_var04_stageD.png',
    );
  });

  test('sequence sheets are only used for their matching model', () {
    expect(PetArt.hasMatchingActionSheet('pet_cat_v1', PetStage.c), isTrue);
    expect(PetArt.hasMatchingActionSheet('pet_cat_v2', PetStage.c), isFalse);
    expect(PetArt.hasMatchingActionSheet('pet_cat_v1', PetStage.d), isFalse);
  });
}
