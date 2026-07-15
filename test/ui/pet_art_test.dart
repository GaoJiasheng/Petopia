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

  test('every growth stage and variant uses the species action sheet', () {
    expect(
      PetArt.actionSheet('pet_cat', 'eat'),
      'assets/runtime/pets/cat/actions/pet_cat_var01_stageC_eat.png',
    );
    expect(
      PetArt.actionSheet('pet_rabbit', 'bath'),
      'assets/runtime/pets/rabbit/actions/pet_rabbit_var01_stageC_bath.png',
    );
  });
}
