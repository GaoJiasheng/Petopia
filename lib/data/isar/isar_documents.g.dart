// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_documents.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPetDocCollection on Isar {
  IsarCollection<PetDoc> get petDocs => this.collection();
}

const PetDocSchema = CollectionSchema(
  name: r'PetDoc',
  id: -8689301214660238586,
  properties: {
    r'bornAt': PropertySchema(
      id: 0,
      name: r'bornAt',
      type: IsarType.dateTime,
    ),
    r'exp': PropertySchema(
      id: 1,
      name: r'exp',
      type: IsarType.long,
    ),
    r'graduatedAt': PropertySchema(
      id: 2,
      name: r'graduatedAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 3,
      name: r'id',
      type: IsarType.string,
    ),
    r'journeyId': PropertySchema(
      id: 4,
      name: r'journeyId',
      type: IsarType.string,
    ),
    r'lastOnlineAt': PropertySchema(
      id: 5,
      name: r'lastOnlineAt',
      type: IsarType.dateTime,
    ),
    r'level': PropertySchema(
      id: 6,
      name: r'level',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 7,
      name: r'name',
      type: IsarType.string,
    ),
    r'nextRevisitAt': PropertySchema(
      id: 8,
      name: r'nextRevisitAt',
      type: IsarType.dateTime,
    ),
    r'offlineDayKey': PropertySchema(
      id: 9,
      name: r'offlineDayKey',
      type: IsarType.string,
    ),
    r'offlineExpGrantedToday': PropertySchema(
      id: 10,
      name: r'offlineExpGrantedToday',
      type: IsarType.long,
    ),
    r'pastNames': PropertySchema(
      id: 11,
      name: r'pastNames',
      type: IsarType.stringList,
    ),
    r'personality': PropertySchema(
      id: 12,
      name: r'personality',
      type: IsarType.stringList,
    ),
    r'speciesId': PropertySchema(
      id: 13,
      name: r'speciesId',
      type: IsarType.string,
    ),
    r'stage': PropertySchema(
      id: 14,
      name: r'stage',
      type: IsarType.string,
      enumMap: _PetDocstageEnumValueMap,
    ),
    r'state': PropertySchema(
      id: 15,
      name: r'state',
      type: IsarType.string,
      enumMap: _PetDocstateEnumValueMap,
    ),
    r'variantId': PropertySchema(
      id: 16,
      name: r'variantId',
      type: IsarType.string,
    ),
    r'wishId': PropertySchema(
      id: 17,
      name: r'wishId',
      type: IsarType.string,
    )
  },
  estimateSize: _petDocEstimateSize,
  serialize: _petDocSerialize,
  deserialize: _petDocDeserialize,
  deserializeProp: _petDocDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'state': IndexSchema(
      id: 7917036384617311412,
      name: r'state',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'state',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _petDocGetId,
  getLinks: _petDocGetLinks,
  attach: _petDocAttach,
  version: '3.1.0+1',
);

int _petDocEstimateSize(
  PetDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.domainId.length * 3;
  {
    final value = object.journeyId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.offlineDayKey.length * 3;
  bytesCount += 3 + object.pastNames.length * 3;
  {
    for (var i = 0; i < object.pastNames.length; i++) {
      final value = object.pastNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.personality.length * 3;
  {
    for (var i = 0; i < object.personality.length; i++) {
      final value = object.personality[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.speciesId.length * 3;
  bytesCount += 3 + object.stage.name.length * 3;
  bytesCount += 3 + object.state.name.length * 3;
  bytesCount += 3 + object.variantId.length * 3;
  {
    final value = object.wishId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _petDocSerialize(
  PetDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.bornAt);
  writer.writeLong(offsets[1], object.exp);
  writer.writeDateTime(offsets[2], object.graduatedAt);
  writer.writeString(offsets[3], object.domainId);
  writer.writeString(offsets[4], object.journeyId);
  writer.writeDateTime(offsets[5], object.lastOnlineAt);
  writer.writeLong(offsets[6], object.level);
  writer.writeString(offsets[7], object.name);
  writer.writeDateTime(offsets[8], object.nextRevisitAt);
  writer.writeString(offsets[9], object.offlineDayKey);
  writer.writeLong(offsets[10], object.offlineExpGrantedToday);
  writer.writeStringList(offsets[11], object.pastNames);
  writer.writeStringList(offsets[12], object.personality);
  writer.writeString(offsets[13], object.speciesId);
  writer.writeString(offsets[14], object.stage.name);
  writer.writeString(offsets[15], object.state.name);
  writer.writeString(offsets[16], object.variantId);
  writer.writeString(offsets[17], object.wishId);
}

PetDoc _petDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PetDoc();
  object.bornAt = reader.readDateTime(offsets[0]);
  object.exp = reader.readLong(offsets[1]);
  object.graduatedAt = reader.readDateTimeOrNull(offsets[2]);
  object.domainId = reader.readString(offsets[3]);
  object.isarId = id;
  object.journeyId = reader.readStringOrNull(offsets[4]);
  object.lastOnlineAt = reader.readDateTime(offsets[5]);
  object.level = reader.readLong(offsets[6]);
  object.name = reader.readString(offsets[7]);
  object.nextRevisitAt = reader.readDateTimeOrNull(offsets[8]);
  object.offlineDayKey = reader.readString(offsets[9]);
  object.offlineExpGrantedToday = reader.readLong(offsets[10]);
  object.pastNames = reader.readStringList(offsets[11]) ?? [];
  object.personality = reader.readStringList(offsets[12]) ?? [];
  object.speciesId = reader.readString(offsets[13]);
  object.stage =
      _PetDocstageValueEnumMap[reader.readStringOrNull(offsets[14])] ??
          PetStage.a;
  object.state =
      _PetDocstateValueEnumMap[reader.readStringOrNull(offsets[15])] ??
          PetState.raising;
  object.variantId = reader.readString(offsets[16]);
  object.wishId = reader.readStringOrNull(offsets[17]);
  return object;
}

P _petDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (_PetDocstageValueEnumMap[reader.readStringOrNull(offset)] ??
          PetStage.a) as P;
    case 15:
      return (_PetDocstateValueEnumMap[reader.readStringOrNull(offset)] ??
          PetState.raising) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PetDocstageEnumValueMap = {
  r'a': r'a',
  r'b': r'b',
  r'c': r'c',
  r'd': r'd',
};
const _PetDocstageValueEnumMap = {
  r'a': PetStage.a,
  r'b': PetStage.b,
  r'c': PetStage.c,
  r'd': PetStage.d,
};
const _PetDocstateEnumValueMap = {
  r'raising': r'raising',
  r'traveling': r'traveling',
  r'roaming': r'roaming',
  r'revisiting': r'revisiting',
  r'graduated': r'graduated',
};
const _PetDocstateValueEnumMap = {
  r'raising': PetState.raising,
  r'traveling': PetState.traveling,
  r'roaming': PetState.roaming,
  r'revisiting': PetState.revisiting,
  r'graduated': PetState.graduated,
};

Id _petDocGetId(PetDoc object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _petDocGetLinks(PetDoc object) {
  return [];
}

void _petDocAttach(IsarCollection<dynamic> col, Id id, PetDoc object) {
  object.isarId = id;
}

extension PetDocQueryWhereSort on QueryBuilder<PetDoc, PetDoc, QWhere> {
  QueryBuilder<PetDoc, PetDoc, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PetDocQueryWhere on QueryBuilder<PetDoc, PetDoc, QWhereClause> {
  QueryBuilder<PetDoc, PetDoc, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterWhereClause> isarIdGreaterThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterWhereClause> isarIdLessThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterWhereClause> domainIdEqualTo(
      String domainId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [domainId],
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterWhereClause> domainIdNotEqualTo(
      String domainId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [domainId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [domainId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [domainId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [domainId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterWhereClause> stateEqualTo(PetState state) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'state',
        value: [state],
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterWhereClause> stateNotEqualTo(
      PetState state) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [],
              upper: [state],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [state],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [state],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [],
              upper: [state],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PetDocQueryFilter on QueryBuilder<PetDoc, PetDoc, QFilterCondition> {
  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> bornAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bornAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> bornAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bornAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> bornAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bornAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> bornAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bornAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> expEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exp',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> expGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exp',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> expLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exp',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> expBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> graduatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'graduatedAt',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> graduatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'graduatedAt',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> graduatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'graduatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> graduatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'graduatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> graduatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'graduatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> graduatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'graduatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> domainIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> domainIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> domainIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> domainIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> domainIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> domainIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> domainIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> domainIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'journeyId',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'journeyId',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'journeyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'journeyId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'journeyId',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> journeyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'journeyId',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> lastOnlineAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastOnlineAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> lastOnlineAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastOnlineAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> lastOnlineAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastOnlineAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> lastOnlineAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastOnlineAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> levelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> levelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> levelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> levelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nextRevisitAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextRevisitAt',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nextRevisitAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextRevisitAt',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nextRevisitAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextRevisitAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nextRevisitAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextRevisitAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nextRevisitAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextRevisitAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> nextRevisitAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextRevisitAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> offlineDayKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offlineDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> offlineDayKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offlineDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> offlineDayKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offlineDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> offlineDayKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offlineDayKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> offlineDayKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'offlineDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> offlineDayKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'offlineDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> offlineDayKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'offlineDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> offlineDayKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'offlineDayKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> offlineDayKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offlineDayKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      offlineDayKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'offlineDayKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      offlineExpGrantedTodayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offlineExpGrantedToday',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      offlineExpGrantedTodayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offlineExpGrantedToday',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      offlineExpGrantedTodayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offlineExpGrantedToday',
        value: value,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      offlineExpGrantedTodayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offlineExpGrantedToday',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pastNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      pastNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pastNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pastNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pastNames',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      pastNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pastNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pastNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pastNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pastNames',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      pastNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pastNames',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      pastNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pastNames',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      pastNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> pastNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pastNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> personalityElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      personalityElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      personalityElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> personalityElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      personalityElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      personalityElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      personalityElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'personality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> personalityElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'personality',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      personalityElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personality',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      personalityElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personality',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> personalityLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> personalityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> personalityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> personalityLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition>
      personalityLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> personalityLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'personality',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> speciesIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speciesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> speciesIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speciesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> speciesIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speciesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> speciesIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speciesId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> speciesIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'speciesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> speciesIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'speciesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> speciesIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'speciesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> speciesIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'speciesId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> speciesIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speciesId',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> speciesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'speciesId',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stageEqualTo(
    PetStage value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stageGreaterThan(
    PetStage value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stageLessThan(
    PetStage value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stageBetween(
    PetStage lower,
    PetStage upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stage',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stage',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stateEqualTo(
    PetState value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stateGreaterThan(
    PetState value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stateLessThan(
    PetState value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stateBetween(
    PetState lower,
    PetState upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'state',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'state',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> stateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> variantIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> variantIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'variantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> variantIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'variantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> variantIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'variantId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> variantIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'variantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> variantIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'variantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> variantIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'variantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> variantIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'variantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> variantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantId',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> variantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'variantId',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'wishId',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'wishId',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wishId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wishId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wishId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wishId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'wishId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'wishId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'wishId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'wishId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wishId',
        value: '',
      ));
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterFilterCondition> wishIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'wishId',
        value: '',
      ));
    });
  }
}

extension PetDocQueryObject on QueryBuilder<PetDoc, PetDoc, QFilterCondition> {}

extension PetDocQueryLinks on QueryBuilder<PetDoc, PetDoc, QFilterCondition> {}

extension PetDocQuerySortBy on QueryBuilder<PetDoc, PetDoc, QSortBy> {
  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByBornAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bornAt', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByBornAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bornAt', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByExp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exp', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByExpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exp', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByGraduatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'graduatedAt', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByGraduatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'graduatedAt', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByJourneyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyId', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByJourneyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyId', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByLastOnlineAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOnlineAt', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByLastOnlineAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOnlineAt', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByNextRevisitAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRevisitAt', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByNextRevisitAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRevisitAt', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByOfflineDayKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineDayKey', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByOfflineDayKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineDayKey', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByOfflineExpGrantedToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineExpGrantedToday', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy>
      sortByOfflineExpGrantedTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineExpGrantedToday', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortBySpeciesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortBySpeciesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByVariantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantId', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByVariantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantId', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByWishId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wishId', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> sortByWishIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wishId', Sort.desc);
    });
  }
}

extension PetDocQuerySortThenBy on QueryBuilder<PetDoc, PetDoc, QSortThenBy> {
  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByBornAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bornAt', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByBornAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bornAt', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByExp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exp', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByExpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exp', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByGraduatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'graduatedAt', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByGraduatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'graduatedAt', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByJourneyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyId', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByJourneyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyId', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByLastOnlineAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOnlineAt', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByLastOnlineAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOnlineAt', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByNextRevisitAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRevisitAt', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByNextRevisitAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRevisitAt', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByOfflineDayKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineDayKey', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByOfflineDayKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineDayKey', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByOfflineExpGrantedToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineExpGrantedToday', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy>
      thenByOfflineExpGrantedTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offlineExpGrantedToday', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenBySpeciesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenBySpeciesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speciesId', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stage', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByVariantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantId', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByVariantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantId', Sort.desc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByWishId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wishId', Sort.asc);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QAfterSortBy> thenByWishIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wishId', Sort.desc);
    });
  }
}

extension PetDocQueryWhereDistinct on QueryBuilder<PetDoc, PetDoc, QDistinct> {
  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByBornAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bornAt');
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByExp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exp');
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByGraduatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'graduatedAt');
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByDomainId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByJourneyId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'journeyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByLastOnlineAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastOnlineAt');
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level');
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByNextRevisitAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextRevisitAt');
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByOfflineDayKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offlineDayKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByOfflineExpGrantedToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offlineExpGrantedToday');
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByPastNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pastNames');
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByPersonality() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personality');
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctBySpeciesId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speciesId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByStage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByState(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'state', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByVariantId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variantId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PetDoc, PetDoc, QDistinct> distinctByWishId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wishId', caseSensitive: caseSensitive);
    });
  }
}

extension PetDocQueryProperty on QueryBuilder<PetDoc, PetDoc, QQueryProperty> {
  QueryBuilder<PetDoc, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<PetDoc, DateTime, QQueryOperations> bornAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bornAt');
    });
  }

  QueryBuilder<PetDoc, int, QQueryOperations> expProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exp');
    });
  }

  QueryBuilder<PetDoc, DateTime?, QQueryOperations> graduatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'graduatedAt');
    });
  }

  QueryBuilder<PetDoc, String, QQueryOperations> domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PetDoc, String?, QQueryOperations> journeyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'journeyId');
    });
  }

  QueryBuilder<PetDoc, DateTime, QQueryOperations> lastOnlineAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastOnlineAt');
    });
  }

  QueryBuilder<PetDoc, int, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }

  QueryBuilder<PetDoc, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<PetDoc, DateTime?, QQueryOperations> nextRevisitAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextRevisitAt');
    });
  }

  QueryBuilder<PetDoc, String, QQueryOperations> offlineDayKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offlineDayKey');
    });
  }

  QueryBuilder<PetDoc, int, QQueryOperations> offlineExpGrantedTodayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offlineExpGrantedToday');
    });
  }

  QueryBuilder<PetDoc, List<String>, QQueryOperations> pastNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pastNames');
    });
  }

  QueryBuilder<PetDoc, List<String>, QQueryOperations> personalityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personality');
    });
  }

  QueryBuilder<PetDoc, String, QQueryOperations> speciesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speciesId');
    });
  }

  QueryBuilder<PetDoc, PetStage, QQueryOperations> stageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stage');
    });
  }

  QueryBuilder<PetDoc, PetState, QQueryOperations> stateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'state');
    });
  }

  QueryBuilder<PetDoc, String, QQueryOperations> variantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variantId');
    });
  }

  QueryBuilder<PetDoc, String?, QQueryOperations> wishIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wishId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCurrencyWalletDocCollection on Isar {
  IsarCollection<CurrencyWalletDoc> get currencyWalletDocs => this.collection();
}

const CurrencyWalletDocSchema = CollectionSchema(
  name: r'CurrencyWalletDoc',
  id: -2691349940995322779,
  properties: {
    r'balance': PropertySchema(
      id: 0,
      name: r'balance',
      type: IsarType.long,
    )
  },
  estimateSize: _currencyWalletDocEstimateSize,
  serialize: _currencyWalletDocSerialize,
  deserialize: _currencyWalletDocDeserialize,
  deserializeProp: _currencyWalletDocDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _currencyWalletDocGetId,
  getLinks: _currencyWalletDocGetLinks,
  attach: _currencyWalletDocAttach,
  version: '3.1.0+1',
);

int _currencyWalletDocEstimateSize(
  CurrencyWalletDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _currencyWalletDocSerialize(
  CurrencyWalletDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.balance);
}

CurrencyWalletDoc _currencyWalletDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CurrencyWalletDoc();
  object.balance = reader.readLong(offsets[0]);
  object.isarId = id;
  return object;
}

P _currencyWalletDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _currencyWalletDocGetId(CurrencyWalletDoc object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _currencyWalletDocGetLinks(
    CurrencyWalletDoc object) {
  return [];
}

void _currencyWalletDocAttach(
    IsarCollection<dynamic> col, Id id, CurrencyWalletDoc object) {
  object.isarId = id;
}

extension CurrencyWalletDocQueryWhereSort
    on QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QWhere> {
  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CurrencyWalletDocQueryWhere
    on QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QWhereClause> {
  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CurrencyWalletDocQueryFilter
    on QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QFilterCondition> {
  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterFilterCondition>
      balanceEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'balance',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterFilterCondition>
      balanceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'balance',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterFilterCondition>
      balanceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'balance',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterFilterCondition>
      balanceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'balance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CurrencyWalletDocQueryObject
    on QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QFilterCondition> {}

extension CurrencyWalletDocQueryLinks
    on QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QFilterCondition> {}

extension CurrencyWalletDocQuerySortBy
    on QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QSortBy> {
  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterSortBy>
      sortByBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balance', Sort.asc);
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterSortBy>
      sortByBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balance', Sort.desc);
    });
  }
}

extension CurrencyWalletDocQuerySortThenBy
    on QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QSortThenBy> {
  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterSortBy>
      thenByBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balance', Sort.asc);
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterSortBy>
      thenByBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'balance', Sort.desc);
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }
}

extension CurrencyWalletDocQueryWhereDistinct
    on QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QDistinct> {
  QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QDistinct>
      distinctByBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'balance');
    });
  }
}

extension CurrencyWalletDocQueryProperty
    on QueryBuilder<CurrencyWalletDoc, CurrencyWalletDoc, QQueryProperty> {
  QueryBuilder<CurrencyWalletDoc, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<CurrencyWalletDoc, int, QQueryOperations> balanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'balance');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetYardStateDocCollection on Isar {
  IsarCollection<YardStateDoc> get yardStateDocs => this.collection();
}

const YardStateDocSchema = CollectionSchema(
  name: r'YardStateDoc',
  id: -9169638615184376169,
  properties: {
    r'activeThemeId': PropertySchema(
      id: 0,
      name: r'activeThemeId',
      type: IsarType.string,
    ),
    r'foodTray': PropertySchema(
      id: 1,
      name: r'foodTray',
      type: IsarType.object,
      target: r'FoodTrayDoc',
    ),
    r'gradCount': PropertySchema(
      id: 2,
      name: r'gradCount',
      type: IsarType.long,
    ),
    r'luxuryStage': PropertySchema(
      id: 3,
      name: r'luxuryStage',
      type: IsarType.long,
    ),
    r'ownedDecorIds': PropertySchema(
      id: 4,
      name: r'ownedDecorIds',
      type: IsarType.stringList,
    ),
    r'ownedPerks': PropertySchema(
      id: 5,
      name: r'ownedPerks',
      type: IsarType.stringList,
    ),
    r'ownedThemeIds': PropertySchema(
      id: 6,
      name: r'ownedThemeIds',
      type: IsarType.stringList,
    ),
    r'slots': PropertySchema(
      id: 7,
      name: r'slots',
      type: IsarType.objectList,
      target: r'YardSlotDoc',
    )
  },
  estimateSize: _yardStateDocEstimateSize,
  serialize: _yardStateDocSerialize,
  deserialize: _yardStateDocDeserialize,
  deserializeProp: _yardStateDocDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {
    r'YardSlotDoc': YardSlotDocSchema,
    r'FoodTrayDoc': FoodTrayDocSchema
  },
  getId: _yardStateDocGetId,
  getLinks: _yardStateDocGetLinks,
  attach: _yardStateDocAttach,
  version: '3.1.0+1',
);

int _yardStateDocEstimateSize(
  YardStateDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activeThemeId.length * 3;
  {
    final value = object.foodTray;
    if (value != null) {
      bytesCount += 3 +
          FoodTrayDocSchema.estimateSize(
              value, allOffsets[FoodTrayDoc]!, allOffsets);
    }
  }
  bytesCount += 3 + object.ownedDecorIds.length * 3;
  {
    for (var i = 0; i < object.ownedDecorIds.length; i++) {
      final value = object.ownedDecorIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.ownedPerks.length * 3;
  {
    for (var i = 0; i < object.ownedPerks.length; i++) {
      final value = object.ownedPerks[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.ownedThemeIds.length * 3;
  {
    for (var i = 0; i < object.ownedThemeIds.length; i++) {
      final value = object.ownedThemeIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.slots.length * 3;
  {
    final offsets = allOffsets[YardSlotDoc]!;
    for (var i = 0; i < object.slots.length; i++) {
      final value = object.slots[i];
      bytesCount += YardSlotDocSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _yardStateDocSerialize(
  YardStateDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activeThemeId);
  writer.writeObject<FoodTrayDoc>(
    offsets[1],
    allOffsets,
    FoodTrayDocSchema.serialize,
    object.foodTray,
  );
  writer.writeLong(offsets[2], object.gradCount);
  writer.writeLong(offsets[3], object.luxuryStage);
  writer.writeStringList(offsets[4], object.ownedDecorIds);
  writer.writeStringList(offsets[5], object.ownedPerks);
  writer.writeStringList(offsets[6], object.ownedThemeIds);
  writer.writeObjectList<YardSlotDoc>(
    offsets[7],
    allOffsets,
    YardSlotDocSchema.serialize,
    object.slots,
  );
}

YardStateDoc _yardStateDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = YardStateDoc();
  object.activeThemeId = reader.readString(offsets[0]);
  object.foodTray = reader.readObjectOrNull<FoodTrayDoc>(
    offsets[1],
    FoodTrayDocSchema.deserialize,
    allOffsets,
  );
  object.gradCount = reader.readLong(offsets[2]);
  object.isarId = id;
  object.luxuryStage = reader.readLong(offsets[3]);
  object.ownedDecorIds = reader.readStringList(offsets[4]) ?? [];
  object.ownedPerks = reader.readStringList(offsets[5]) ?? [];
  object.ownedThemeIds = reader.readStringList(offsets[6]) ?? [];
  object.slots = reader.readObjectList<YardSlotDoc>(
        offsets[7],
        YardSlotDocSchema.deserialize,
        allOffsets,
        YardSlotDoc(),
      ) ??
      [];
  return object;
}

P _yardStateDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readObjectOrNull<FoodTrayDoc>(
        offset,
        FoodTrayDocSchema.deserialize,
        allOffsets,
      )) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readObjectList<YardSlotDoc>(
            offset,
            YardSlotDocSchema.deserialize,
            allOffsets,
            YardSlotDoc(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _yardStateDocGetId(YardStateDoc object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _yardStateDocGetLinks(YardStateDoc object) {
  return [];
}

void _yardStateDocAttach(
    IsarCollection<dynamic> col, Id id, YardStateDoc object) {
  object.isarId = id;
}

extension YardStateDocQueryWhereSort
    on QueryBuilder<YardStateDoc, YardStateDoc, QWhere> {
  QueryBuilder<YardStateDoc, YardStateDoc, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension YardStateDocQueryWhere
    on QueryBuilder<YardStateDoc, YardStateDoc, QWhereClause> {
  QueryBuilder<YardStateDoc, YardStateDoc, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension YardStateDocQueryFilter
    on QueryBuilder<YardStateDoc, YardStateDoc, QFilterCondition> {
  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      activeThemeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeThemeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      activeThemeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeThemeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      activeThemeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeThemeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      activeThemeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeThemeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      activeThemeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeThemeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      activeThemeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeThemeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      activeThemeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeThemeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      activeThemeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeThemeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      activeThemeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeThemeId',
        value: '',
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      activeThemeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeThemeId',
        value: '',
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      foodTrayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'foodTray',
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      foodTrayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'foodTray',
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      gradCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gradCount',
        value: value,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      gradCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gradCount',
        value: value,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      gradCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gradCount',
        value: value,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      gradCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gradCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      luxuryStageEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'luxuryStage',
        value: value,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      luxuryStageGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'luxuryStage',
        value: value,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      luxuryStageLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'luxuryStage',
        value: value,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      luxuryStageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'luxuryStage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownedDecorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ownedDecorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ownedDecorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ownedDecorIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ownedDecorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ownedDecorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ownedDecorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ownedDecorIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownedDecorIds',
        value: '',
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ownedDecorIds',
        value: '',
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedDecorIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedDecorIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedDecorIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedDecorIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedDecorIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedDecorIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedDecorIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownedPerks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ownedPerks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ownedPerks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ownedPerks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ownedPerks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ownedPerks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ownedPerks',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ownedPerks',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownedPerks',
        value: '',
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ownedPerks',
        value: '',
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedPerks',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedPerks',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedPerks',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedPerks',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedPerks',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedPerksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedPerks',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownedThemeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ownedThemeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ownedThemeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ownedThemeIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ownedThemeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ownedThemeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ownedThemeIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ownedThemeIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownedThemeIds',
        value: '',
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ownedThemeIds',
        value: '',
      ));
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedThemeIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedThemeIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedThemeIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedThemeIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedThemeIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      ownedThemeIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ownedThemeIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      slotsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      slotsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      slotsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      slotsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      slotsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition>
      slotsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension YardStateDocQueryObject
    on QueryBuilder<YardStateDoc, YardStateDoc, QFilterCondition> {
  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition> foodTray(
      FilterQuery<FoodTrayDoc> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'foodTray');
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterFilterCondition> slotsElement(
      FilterQuery<YardSlotDoc> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'slots');
    });
  }
}

extension YardStateDocQueryLinks
    on QueryBuilder<YardStateDoc, YardStateDoc, QFilterCondition> {}

extension YardStateDocQuerySortBy
    on QueryBuilder<YardStateDoc, YardStateDoc, QSortBy> {
  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy> sortByActiveThemeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeThemeId', Sort.asc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy>
      sortByActiveThemeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeThemeId', Sort.desc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy> sortByGradCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gradCount', Sort.asc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy> sortByGradCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gradCount', Sort.desc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy> sortByLuxuryStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'luxuryStage', Sort.asc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy>
      sortByLuxuryStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'luxuryStage', Sort.desc);
    });
  }
}

extension YardStateDocQuerySortThenBy
    on QueryBuilder<YardStateDoc, YardStateDoc, QSortThenBy> {
  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy> thenByActiveThemeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeThemeId', Sort.asc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy>
      thenByActiveThemeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeThemeId', Sort.desc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy> thenByGradCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gradCount', Sort.asc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy> thenByGradCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gradCount', Sort.desc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy> thenByLuxuryStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'luxuryStage', Sort.asc);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QAfterSortBy>
      thenByLuxuryStageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'luxuryStage', Sort.desc);
    });
  }
}

extension YardStateDocQueryWhereDistinct
    on QueryBuilder<YardStateDoc, YardStateDoc, QDistinct> {
  QueryBuilder<YardStateDoc, YardStateDoc, QDistinct> distinctByActiveThemeId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeThemeId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QDistinct> distinctByGradCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gradCount');
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QDistinct> distinctByLuxuryStage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'luxuryStage');
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QDistinct>
      distinctByOwnedDecorIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownedDecorIds');
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QDistinct> distinctByOwnedPerks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownedPerks');
    });
  }

  QueryBuilder<YardStateDoc, YardStateDoc, QDistinct>
      distinctByOwnedThemeIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownedThemeIds');
    });
  }
}

extension YardStateDocQueryProperty
    on QueryBuilder<YardStateDoc, YardStateDoc, QQueryProperty> {
  QueryBuilder<YardStateDoc, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<YardStateDoc, String, QQueryOperations> activeThemeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeThemeId');
    });
  }

  QueryBuilder<YardStateDoc, FoodTrayDoc?, QQueryOperations>
      foodTrayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foodTray');
    });
  }

  QueryBuilder<YardStateDoc, int, QQueryOperations> gradCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gradCount');
    });
  }

  QueryBuilder<YardStateDoc, int, QQueryOperations> luxuryStageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'luxuryStage');
    });
  }

  QueryBuilder<YardStateDoc, List<String>, QQueryOperations>
      ownedDecorIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownedDecorIds');
    });
  }

  QueryBuilder<YardStateDoc, List<String>, QQueryOperations>
      ownedPerksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownedPerks');
    });
  }

  QueryBuilder<YardStateDoc, List<String>, QQueryOperations>
      ownedThemeIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownedThemeIds');
    });
  }

  QueryBuilder<YardStateDoc, List<YardSlotDoc>, QQueryOperations>
      slotsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slots');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetJourneyDocCollection on Isar {
  IsarCollection<JourneyDoc> get journeyDocs => this.collection();
}

const JourneyDocSchema = CollectionSchema(
  name: r'JourneyDoc',
  id: -7337924087321680347,
  properties: {
    r'currentIdx': PropertySchema(
      id: 0,
      name: r'currentIdx',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'nextPostcardAt': PropertySchema(
      id: 2,
      name: r'nextPostcardAt',
      type: IsarType.dateTime,
    ),
    r'petId': PropertySchema(
      id: 3,
      name: r'petId',
      type: IsarType.string,
    ),
    r'state': PropertySchema(
      id: 4,
      name: r'state',
      type: IsarType.string,
      enumMap: _JourneyDocstateEnumValueMap,
    ),
    r'stops': PropertySchema(
      id: 5,
      name: r'stops',
      type: IsarType.stringList,
    )
  },
  estimateSize: _journeyDocEstimateSize,
  serialize: _journeyDocSerialize,
  deserialize: _journeyDocDeserialize,
  deserializeProp: _journeyDocDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'petId': IndexSchema(
      id: -7951607706841349632,
      name: r'petId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'petId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'state': IndexSchema(
      id: 7917036384617311412,
      name: r'state',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'state',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _journeyDocGetId,
  getLinks: _journeyDocGetLinks,
  attach: _journeyDocAttach,
  version: '3.1.0+1',
);

int _journeyDocEstimateSize(
  JourneyDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.domainId.length * 3;
  bytesCount += 3 + object.petId.length * 3;
  bytesCount += 3 + object.state.name.length * 3;
  bytesCount += 3 + object.stops.length * 3;
  {
    for (var i = 0; i < object.stops.length; i++) {
      final value = object.stops[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _journeyDocSerialize(
  JourneyDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentIdx);
  writer.writeString(offsets[1], object.domainId);
  writer.writeDateTime(offsets[2], object.nextPostcardAt);
  writer.writeString(offsets[3], object.petId);
  writer.writeString(offsets[4], object.state.name);
  writer.writeStringList(offsets[5], object.stops);
}

JourneyDoc _journeyDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = JourneyDoc();
  object.currentIdx = reader.readLong(offsets[0]);
  object.domainId = reader.readString(offsets[1]);
  object.isarId = id;
  object.nextPostcardAt = reader.readDateTime(offsets[2]);
  object.petId = reader.readString(offsets[3]);
  object.state =
      _JourneyDocstateValueEnumMap[reader.readStringOrNull(offsets[4])] ??
          JourneyState.active;
  object.stops = reader.readStringList(offsets[5]) ?? [];
  return object;
}

P _journeyDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_JourneyDocstateValueEnumMap[reader.readStringOrNull(offset)] ??
          JourneyState.active) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _JourneyDocstateEnumValueMap = {
  r'active': r'active',
  r'wandering': r'wandering',
  r'done': r'done',
};
const _JourneyDocstateValueEnumMap = {
  r'active': JourneyState.active,
  r'wandering': JourneyState.wandering,
  r'done': JourneyState.done,
};

Id _journeyDocGetId(JourneyDoc object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _journeyDocGetLinks(JourneyDoc object) {
  return [];
}

void _journeyDocAttach(IsarCollection<dynamic> col, Id id, JourneyDoc object) {
  object.isarId = id;
}

extension JourneyDocQueryWhereSort
    on QueryBuilder<JourneyDoc, JourneyDoc, QWhere> {
  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension JourneyDocQueryWhere
    on QueryBuilder<JourneyDoc, JourneyDoc, QWhereClause> {
  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> domainIdEqualTo(
      String domainId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [domainId],
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> domainIdNotEqualTo(
      String domainId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [domainId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [domainId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [domainId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [domainId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> petIdEqualTo(
      String petId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'petId',
        value: [petId],
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> petIdNotEqualTo(
      String petId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'petId',
              lower: [],
              upper: [petId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'petId',
              lower: [petId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'petId',
              lower: [petId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'petId',
              lower: [],
              upper: [petId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> stateEqualTo(
      JourneyState state) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'state',
        value: [state],
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterWhereClause> stateNotEqualTo(
      JourneyState state) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [],
              upper: [state],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [state],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [state],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [],
              upper: [state],
              includeUpper: false,
            ));
      }
    });
  }
}

extension JourneyDocQueryFilter
    on QueryBuilder<JourneyDoc, JourneyDoc, QFilterCondition> {
  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> currentIdxEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentIdx',
        value: value,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      currentIdxGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentIdx',
        value: value,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      currentIdxLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentIdx',
        value: value,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> currentIdxBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentIdx',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> domainIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      domainIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> domainIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> domainIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      domainIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> domainIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> domainIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> domainIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      nextPostcardAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextPostcardAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      nextPostcardAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextPostcardAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      nextPostcardAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextPostcardAt',
        value: value,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      nextPostcardAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextPostcardAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> petIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'petId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> petIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'petId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> petIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'petId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> petIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'petId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> petIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'petId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> petIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'petId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> petIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'petId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> petIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'petId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> petIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'petId',
        value: '',
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      petIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'petId',
        value: '',
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> stateEqualTo(
    JourneyState value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> stateGreaterThan(
    JourneyState value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> stateLessThan(
    JourneyState value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> stateBetween(
    JourneyState lower,
    JourneyState upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'state',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> stateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> stateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> stateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> stateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'state',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> stateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stops',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stops',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stops',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stops',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stops',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stops',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stops',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stops',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stops',
        value: '',
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stops',
        value: '',
      ));
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stops',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition> stopsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stops',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stops',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stops',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stops',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterFilterCondition>
      stopsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'stops',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension JourneyDocQueryObject
    on QueryBuilder<JourneyDoc, JourneyDoc, QFilterCondition> {}

extension JourneyDocQueryLinks
    on QueryBuilder<JourneyDoc, JourneyDoc, QFilterCondition> {}

extension JourneyDocQuerySortBy
    on QueryBuilder<JourneyDoc, JourneyDoc, QSortBy> {
  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> sortByCurrentIdx() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIdx', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> sortByCurrentIdxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIdx', Sort.desc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> sortByNextPostcardAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPostcardAt', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy>
      sortByNextPostcardAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPostcardAt', Sort.desc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> sortByPetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'petId', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> sortByPetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'petId', Sort.desc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> sortByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> sortByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }
}

extension JourneyDocQuerySortThenBy
    on QueryBuilder<JourneyDoc, JourneyDoc, QSortThenBy> {
  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByCurrentIdx() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIdx', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByCurrentIdxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIdx', Sort.desc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByNextPostcardAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPostcardAt', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy>
      thenByNextPostcardAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPostcardAt', Sort.desc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByPetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'petId', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByPetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'petId', Sort.desc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QAfterSortBy> thenByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }
}

extension JourneyDocQueryWhereDistinct
    on QueryBuilder<JourneyDoc, JourneyDoc, QDistinct> {
  QueryBuilder<JourneyDoc, JourneyDoc, QDistinct> distinctByCurrentIdx() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentIdx');
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QDistinct> distinctByDomainId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QDistinct> distinctByNextPostcardAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextPostcardAt');
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QDistinct> distinctByPetId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'petId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QDistinct> distinctByState(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'state', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<JourneyDoc, JourneyDoc, QDistinct> distinctByStops() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stops');
    });
  }
}

extension JourneyDocQueryProperty
    on QueryBuilder<JourneyDoc, JourneyDoc, QQueryProperty> {
  QueryBuilder<JourneyDoc, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<JourneyDoc, int, QQueryOperations> currentIdxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentIdx');
    });
  }

  QueryBuilder<JourneyDoc, String, QQueryOperations> domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<JourneyDoc, DateTime, QQueryOperations>
      nextPostcardAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextPostcardAt');
    });
  }

  QueryBuilder<JourneyDoc, String, QQueryOperations> petIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'petId');
    });
  }

  QueryBuilder<JourneyDoc, JourneyState, QQueryOperations> stateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'state');
    });
  }

  QueryBuilder<JourneyDoc, List<String>, QQueryOperations> stopsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stops');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClueCounterDocCollection on Isar {
  IsarCollection<ClueCounterDoc> get clueCounterDocs => this.collection();
}

const ClueCounterDocSchema = CollectionSchema(
  name: r'ClueCounterDoc',
  id: 2741266274787796764,
  properties: {
    r'clueId': PropertySchema(
      id: 0,
      name: r'clueId',
      type: IsarType.string,
    ),
    r'count': PropertySchema(
      id: 1,
      name: r'count',
      type: IsarType.long,
    ),
    r'threshold': PropertySchema(
      id: 2,
      name: r'threshold',
      type: IsarType.long,
    ),
    r'visitorSeen': PropertySchema(
      id: 3,
      name: r'visitorSeen',
      type: IsarType.bool,
    )
  },
  estimateSize: _clueCounterDocEstimateSize,
  serialize: _clueCounterDocSerialize,
  deserialize: _clueCounterDocDeserialize,
  deserializeProp: _clueCounterDocDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'clueId': IndexSchema(
      id: 5150314804827246450,
      name: r'clueId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'clueId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _clueCounterDocGetId,
  getLinks: _clueCounterDocGetLinks,
  attach: _clueCounterDocAttach,
  version: '3.1.0+1',
);

int _clueCounterDocEstimateSize(
  ClueCounterDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.clueId.length * 3;
  return bytesCount;
}

void _clueCounterDocSerialize(
  ClueCounterDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.clueId);
  writer.writeLong(offsets[1], object.count);
  writer.writeLong(offsets[2], object.threshold);
  writer.writeBool(offsets[3], object.visitorSeen);
}

ClueCounterDoc _clueCounterDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClueCounterDoc();
  object.clueId = reader.readString(offsets[0]);
  object.count = reader.readLong(offsets[1]);
  object.isarId = id;
  object.threshold = reader.readLong(offsets[2]);
  object.visitorSeen = reader.readBool(offsets[3]);
  return object;
}

P _clueCounterDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _clueCounterDocGetId(ClueCounterDoc object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _clueCounterDocGetLinks(ClueCounterDoc object) {
  return [];
}

void _clueCounterDocAttach(
    IsarCollection<dynamic> col, Id id, ClueCounterDoc object) {
  object.isarId = id;
}

extension ClueCounterDocQueryWhereSort
    on QueryBuilder<ClueCounterDoc, ClueCounterDoc, QWhere> {
  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ClueCounterDocQueryWhere
    on QueryBuilder<ClueCounterDoc, ClueCounterDoc, QWhereClause> {
  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterWhereClause> clueIdEqualTo(
      String clueId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'clueId',
        value: [clueId],
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterWhereClause>
      clueIdNotEqualTo(String clueId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clueId',
              lower: [],
              upper: [clueId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clueId',
              lower: [clueId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clueId',
              lower: [clueId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clueId',
              lower: [],
              upper: [clueId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ClueCounterDocQueryFilter
    on QueryBuilder<ClueCounterDoc, ClueCounterDoc, QFilterCondition> {
  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      clueIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      clueIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      clueIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      clueIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clueId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      clueIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      clueIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      clueIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clueId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      clueIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clueId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      clueIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clueId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      clueIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clueId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      countEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      countGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      countLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      countBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'count',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      thresholdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'threshold',
        value: value,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      thresholdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'threshold',
        value: value,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      thresholdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'threshold',
        value: value,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      thresholdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'threshold',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterFilterCondition>
      visitorSeenEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitorSeen',
        value: value,
      ));
    });
  }
}

extension ClueCounterDocQueryObject
    on QueryBuilder<ClueCounterDoc, ClueCounterDoc, QFilterCondition> {}

extension ClueCounterDocQueryLinks
    on QueryBuilder<ClueCounterDoc, ClueCounterDoc, QFilterCondition> {}

extension ClueCounterDocQuerySortBy
    on QueryBuilder<ClueCounterDoc, ClueCounterDoc, QSortBy> {
  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy> sortByClueId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clueId', Sort.asc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy>
      sortByClueIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clueId', Sort.desc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy> sortByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy> sortByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy> sortByThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threshold', Sort.asc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy>
      sortByThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threshold', Sort.desc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy>
      sortByVisitorSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorSeen', Sort.asc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy>
      sortByVisitorSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorSeen', Sort.desc);
    });
  }
}

extension ClueCounterDocQuerySortThenBy
    on QueryBuilder<ClueCounterDoc, ClueCounterDoc, QSortThenBy> {
  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy> thenByClueId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clueId', Sort.asc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy>
      thenByClueIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clueId', Sort.desc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy> thenByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy> thenByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy> thenByThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threshold', Sort.asc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy>
      thenByThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threshold', Sort.desc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy>
      thenByVisitorSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorSeen', Sort.asc);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QAfterSortBy>
      thenByVisitorSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorSeen', Sort.desc);
    });
  }
}

extension ClueCounterDocQueryWhereDistinct
    on QueryBuilder<ClueCounterDoc, ClueCounterDoc, QDistinct> {
  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QDistinct> distinctByClueId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clueId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QDistinct> distinctByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'count');
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QDistinct>
      distinctByThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'threshold');
    });
  }

  QueryBuilder<ClueCounterDoc, ClueCounterDoc, QDistinct>
      distinctByVisitorSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visitorSeen');
    });
  }
}

extension ClueCounterDocQueryProperty
    on QueryBuilder<ClueCounterDoc, ClueCounterDoc, QQueryProperty> {
  QueryBuilder<ClueCounterDoc, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ClueCounterDoc, String, QQueryOperations> clueIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clueId');
    });
  }

  QueryBuilder<ClueCounterDoc, int, QQueryOperations> countProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'count');
    });
  }

  QueryBuilder<ClueCounterDoc, int, QQueryOperations> thresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'threshold');
    });
  }

  QueryBuilder<ClueCounterDoc, bool, QQueryOperations> visitorSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visitorSeen');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAchievementProgressDocCollection on Isar {
  IsarCollection<AchievementProgressDoc> get achievementProgressDocs =>
      this.collection();
}

const AchievementProgressDocSchema = CollectionSchema(
  name: r'AchievementProgressDoc',
  id: 7002371474386779212,
  properties: {
    r'achievementId': PropertySchema(
      id: 0,
      name: r'achievementId',
      type: IsarType.string,
    ),
    r'progress': PropertySchema(
      id: 1,
      name: r'progress',
      type: IsarType.long,
    ),
    r'rewardClaimed': PropertySchema(
      id: 2,
      name: r'rewardClaimed',
      type: IsarType.bool,
    ),
    r'unlockedAt': PropertySchema(
      id: 3,
      name: r'unlockedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _achievementProgressDocEstimateSize,
  serialize: _achievementProgressDocSerialize,
  deserialize: _achievementProgressDocDeserialize,
  deserializeProp: _achievementProgressDocDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'achievementId': IndexSchema(
      id: 547487615361511857,
      name: r'achievementId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'achievementId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _achievementProgressDocGetId,
  getLinks: _achievementProgressDocGetLinks,
  attach: _achievementProgressDocAttach,
  version: '3.1.0+1',
);

int _achievementProgressDocEstimateSize(
  AchievementProgressDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.achievementId.length * 3;
  return bytesCount;
}

void _achievementProgressDocSerialize(
  AchievementProgressDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.achievementId);
  writer.writeLong(offsets[1], object.progress);
  writer.writeBool(offsets[2], object.rewardClaimed);
  writer.writeDateTime(offsets[3], object.unlockedAt);
}

AchievementProgressDoc _achievementProgressDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AchievementProgressDoc();
  object.achievementId = reader.readString(offsets[0]);
  object.isarId = id;
  object.progress = reader.readLong(offsets[1]);
  object.rewardClaimed = reader.readBool(offsets[2]);
  object.unlockedAt = reader.readDateTimeOrNull(offsets[3]);
  return object;
}

P _achievementProgressDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _achievementProgressDocGetId(AchievementProgressDoc object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _achievementProgressDocGetLinks(
    AchievementProgressDoc object) {
  return [];
}

void _achievementProgressDocAttach(
    IsarCollection<dynamic> col, Id id, AchievementProgressDoc object) {
  object.isarId = id;
}

extension AchievementProgressDocQueryWhereSort
    on QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QWhere> {
  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AchievementProgressDocQueryWhere on QueryBuilder<
    AchievementProgressDoc, AchievementProgressDoc, QWhereClause> {
  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterWhereClause> achievementIdEqualTo(String achievementId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'achievementId',
        value: [achievementId],
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterWhereClause> achievementIdNotEqualTo(String achievementId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [],
              upper: [achievementId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [achievementId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [achievementId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'achievementId',
              lower: [],
              upper: [achievementId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AchievementProgressDocQueryFilter on QueryBuilder<
    AchievementProgressDoc, AchievementProgressDoc, QFilterCondition> {
  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> achievementIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> achievementIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> achievementIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> achievementIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'achievementId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> achievementIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> achievementIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
          QAfterFilterCondition>
      achievementIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'achievementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
          QAfterFilterCondition>
      achievementIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'achievementId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> achievementIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'achievementId',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> achievementIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'achievementId',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> progressEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> progressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> progressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> progressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> rewardClaimedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rewardClaimed',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> unlockedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> unlockedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> unlockedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> unlockedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> unlockedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc,
      QAfterFilterCondition> unlockedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AchievementProgressDocQueryObject on QueryBuilder<
    AchievementProgressDoc, AchievementProgressDoc, QFilterCondition> {}

extension AchievementProgressDocQueryLinks on QueryBuilder<
    AchievementProgressDoc, AchievementProgressDoc, QFilterCondition> {}

extension AchievementProgressDocQuerySortBy
    on QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QSortBy> {
  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      sortByAchievementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.asc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      sortByAchievementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.desc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      sortByRewardClaimed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardClaimed', Sort.asc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      sortByRewardClaimedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardClaimed', Sort.desc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      sortByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      sortByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension AchievementProgressDocQuerySortThenBy on QueryBuilder<
    AchievementProgressDoc, AchievementProgressDoc, QSortThenBy> {
  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      thenByAchievementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.asc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      thenByAchievementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementId', Sort.desc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      thenByRewardClaimed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardClaimed', Sort.asc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      thenByRewardClaimedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardClaimed', Sort.desc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      thenByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QAfterSortBy>
      thenByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension AchievementProgressDocQueryWhereDistinct
    on QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QDistinct> {
  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QDistinct>
      distinctByAchievementId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'achievementId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QDistinct>
      distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QDistinct>
      distinctByRewardClaimed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rewardClaimed');
    });
  }

  QueryBuilder<AchievementProgressDoc, AchievementProgressDoc, QDistinct>
      distinctByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAt');
    });
  }
}

extension AchievementProgressDocQueryProperty on QueryBuilder<
    AchievementProgressDoc, AchievementProgressDoc, QQueryProperty> {
  QueryBuilder<AchievementProgressDoc, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<AchievementProgressDoc, String, QQueryOperations>
      achievementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'achievementId');
    });
  }

  QueryBuilder<AchievementProgressDoc, int, QQueryOperations>
      progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<AchievementProgressDoc, bool, QQueryOperations>
      rewardClaimedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rewardClaimed');
    });
  }

  QueryBuilder<AchievementProgressDoc, DateTime?, QQueryOperations>
      unlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVisitorLogEntryDocCollection on Isar {
  IsarCollection<VisitorLogEntryDoc> get visitorLogEntryDocs =>
      this.collection();
}

const VisitorLogEntryDocSchema = CollectionSchema(
  name: r'VisitorLogEntryDoc',
  id: -6215140020601798695,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'interactionId': PropertySchema(
      id: 2,
      name: r'interactionId',
      type: IsarType.string,
    ),
    r'visitorId': PropertySchema(
      id: 3,
      name: r'visitorId',
      type: IsarType.string,
    ),
    r'withPetId': PropertySchema(
      id: 4,
      name: r'withPetId',
      type: IsarType.string,
    )
  },
  estimateSize: _visitorLogEntryDocEstimateSize,
  serialize: _visitorLogEntryDocSerialize,
  deserialize: _visitorLogEntryDocDeserialize,
  deserializeProp: _visitorLogEntryDocDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'visitorId': IndexSchema(
      id: -7466299045397464900,
      name: r'visitorId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'visitorId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'withPetId': IndexSchema(
      id: -7778260534482080605,
      name: r'withPetId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'withPetId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _visitorLogEntryDocGetId,
  getLinks: _visitorLogEntryDocGetLinks,
  attach: _visitorLogEntryDocAttach,
  version: '3.1.0+1',
);

int _visitorLogEntryDocEstimateSize(
  VisitorLogEntryDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.domainId.length * 3;
  {
    final value = object.interactionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.visitorId.length * 3;
  {
    final value = object.withPetId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _visitorLogEntryDocSerialize(
  VisitorLogEntryDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeString(offsets[1], object.domainId);
  writer.writeString(offsets[2], object.interactionId);
  writer.writeString(offsets[3], object.visitorId);
  writer.writeString(offsets[4], object.withPetId);
}

VisitorLogEntryDoc _visitorLogEntryDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VisitorLogEntryDoc();
  object.date = reader.readDateTime(offsets[0]);
  object.domainId = reader.readString(offsets[1]);
  object.interactionId = reader.readStringOrNull(offsets[2]);
  object.isarId = id;
  object.visitorId = reader.readString(offsets[3]);
  object.withPetId = reader.readStringOrNull(offsets[4]);
  return object;
}

P _visitorLogEntryDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _visitorLogEntryDocGetId(VisitorLogEntryDoc object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _visitorLogEntryDocGetLinks(
    VisitorLogEntryDoc object) {
  return [];
}

void _visitorLogEntryDocAttach(
    IsarCollection<dynamic> col, Id id, VisitorLogEntryDoc object) {
  object.isarId = id;
}

extension VisitorLogEntryDocQueryWhereSort
    on QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QWhere> {
  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension VisitorLogEntryDocQueryWhere
    on QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QWhereClause> {
  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      domainIdEqualTo(String domainId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [domainId],
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      domainIdNotEqualTo(String domainId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [domainId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [domainId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [domainId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [domainId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      visitorIdEqualTo(String visitorId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'visitorId',
        value: [visitorId],
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      visitorIdNotEqualTo(String visitorId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitorId',
              lower: [],
              upper: [visitorId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitorId',
              lower: [visitorId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitorId',
              lower: [visitorId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitorId',
              lower: [],
              upper: [visitorId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      withPetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'withPetId',
        value: [null],
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      withPetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'withPetId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      withPetIdEqualTo(String? withPetId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'withPetId',
        value: [withPetId],
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterWhereClause>
      withPetIdNotEqualTo(String? withPetId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'withPetId',
              lower: [],
              upper: [withPetId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'withPetId',
              lower: [withPetId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'withPetId',
              lower: [withPetId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'withPetId',
              lower: [],
              upper: [withPetId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VisitorLogEntryDocQueryFilter
    on QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QFilterCondition> {
  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      domainIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      domainIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      domainIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      domainIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      domainIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      domainIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      domainIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      domainIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'interactionId',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'interactionId',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'interactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'interactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'interactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'interactionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interactionId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      interactionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'interactionId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      visitorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      visitorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      visitorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      visitorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visitorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      visitorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      visitorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      visitorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      visitorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visitorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      visitorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitorId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      visitorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visitorId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'withPetId',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'withPetId',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'withPetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'withPetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'withPetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'withPetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'withPetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'withPetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'withPetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'withPetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'withPetId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterFilterCondition>
      withPetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'withPetId',
        value: '',
      ));
    });
  }
}

extension VisitorLogEntryDocQueryObject
    on QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QFilterCondition> {}

extension VisitorLogEntryDocQueryLinks
    on QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QFilterCondition> {}

extension VisitorLogEntryDocQuerySortBy
    on QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QSortBy> {
  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      sortByInteractionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interactionId', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      sortByInteractionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interactionId', Sort.desc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      sortByVisitorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      sortByVisitorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.desc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      sortByWithPetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withPetId', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      sortByWithPetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withPetId', Sort.desc);
    });
  }
}

extension VisitorLogEntryDocQuerySortThenBy
    on QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QSortThenBy> {
  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByInteractionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interactionId', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByInteractionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interactionId', Sort.desc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByVisitorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByVisitorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.desc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByWithPetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withPetId', Sort.asc);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QAfterSortBy>
      thenByWithPetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withPetId', Sort.desc);
    });
  }
}

extension VisitorLogEntryDocQueryWhereDistinct
    on QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QDistinct> {
  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QDistinct>
      distinctByDomainId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QDistinct>
      distinctByInteractionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interactionId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QDistinct>
      distinctByVisitorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visitorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QDistinct>
      distinctByWithPetId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'withPetId', caseSensitive: caseSensitive);
    });
  }
}

extension VisitorLogEntryDocQueryProperty
    on QueryBuilder<VisitorLogEntryDoc, VisitorLogEntryDoc, QQueryProperty> {
  QueryBuilder<VisitorLogEntryDoc, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<VisitorLogEntryDoc, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<VisitorLogEntryDoc, String, QQueryOperations>
      domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VisitorLogEntryDoc, String?, QQueryOperations>
      interactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interactionId');
    });
  }

  QueryBuilder<VisitorLogEntryDoc, String, QQueryOperations>
      visitorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visitorId');
    });
  }

  QueryBuilder<VisitorLogEntryDoc, String?, QQueryOperations>
      withPetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'withPetId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScheduledJobDocCollection on Isar {
  IsarCollection<ScheduledJobDoc> get scheduledJobDocs => this.collection();
}

const ScheduledJobDocSchema = CollectionSchema(
  name: r'ScheduledJobDoc',
  id: 7761849853185639242,
  properties: {
    r'consumed': PropertySchema(
      id: 0,
      name: r'consumed',
      type: IsarType.bool,
    ),
    r'dueAt': PropertySchema(
      id: 1,
      name: r'dueAt',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.string,
    ),
    r'payloadRef': PropertySchema(
      id: 3,
      name: r'payloadRef',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 4,
      name: r'priority',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 5,
      name: r'type',
      type: IsarType.string,
      enumMap: _ScheduledJobDoctypeEnumValueMap,
    )
  },
  estimateSize: _scheduledJobDocEstimateSize,
  serialize: _scheduledJobDocSerialize,
  deserialize: _scheduledJobDocDeserialize,
  deserializeProp: _scheduledJobDocDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'type': IndexSchema(
      id: 5117122708147080838,
      name: r'type',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'type',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'dueAt': IndexSchema(
      id: 3701044435752459706,
      name: r'dueAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dueAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'consumed': IndexSchema(
      id: 1196921977313145160,
      name: r'consumed',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'consumed',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _scheduledJobDocGetId,
  getLinks: _scheduledJobDocGetLinks,
  attach: _scheduledJobDocAttach,
  version: '3.1.0+1',
);

int _scheduledJobDocEstimateSize(
  ScheduledJobDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.domainId.length * 3;
  {
    final value = object.payloadRef;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _scheduledJobDocSerialize(
  ScheduledJobDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.consumed);
  writer.writeDateTime(offsets[1], object.dueAt);
  writer.writeString(offsets[2], object.domainId);
  writer.writeString(offsets[3], object.payloadRef);
  writer.writeLong(offsets[4], object.priority);
  writer.writeString(offsets[5], object.type.name);
}

ScheduledJobDoc _scheduledJobDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScheduledJobDoc();
  object.consumed = reader.readBool(offsets[0]);
  object.dueAt = reader.readDateTime(offsets[1]);
  object.domainId = reader.readString(offsets[2]);
  object.isarId = id;
  object.payloadRef = reader.readStringOrNull(offsets[3]);
  object.priority = reader.readLong(offsets[4]);
  object.type =
      _ScheduledJobDoctypeValueEnumMap[reader.readStringOrNull(offsets[5])] ??
          JobType.dailyEventGen;
  return object;
}

P _scheduledJobDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (_ScheduledJobDoctypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          JobType.dailyEventGen) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ScheduledJobDoctypeEnumValueMap = {
  r'dailyEventGen': r'dailyEventGen',
  r'visitorCheck': r'visitorCheck',
  r'revisitDue': r'revisitDue',
  r'postcardDue': r'postcardDue',
  r'specialEventEval': r'specialEventEval',
};
const _ScheduledJobDoctypeValueEnumMap = {
  r'dailyEventGen': JobType.dailyEventGen,
  r'visitorCheck': JobType.visitorCheck,
  r'revisitDue': JobType.revisitDue,
  r'postcardDue': JobType.postcardDue,
  r'specialEventEval': JobType.specialEventEval,
};

Id _scheduledJobDocGetId(ScheduledJobDoc object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _scheduledJobDocGetLinks(ScheduledJobDoc object) {
  return [];
}

void _scheduledJobDocAttach(
    IsarCollection<dynamic> col, Id id, ScheduledJobDoc object) {
  object.isarId = id;
}

extension ScheduledJobDocQueryWhereSort
    on QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QWhere> {
  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhere> anyDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dueAt'),
      );
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhere> anyConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'consumed'),
      );
    });
  }
}

extension ScheduledJobDocQueryWhere
    on QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QWhereClause> {
  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      domainIdEqualTo(String domainId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [domainId],
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      domainIdNotEqualTo(String domainId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [domainId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [domainId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [domainId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [domainId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause> typeEqualTo(
      JobType type) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'type',
        value: [type],
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      typeNotEqualTo(JobType type) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [type],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'type',
              lower: [],
              upper: [type],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      dueAtEqualTo(DateTime dueAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dueAt',
        value: [dueAt],
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      dueAtNotEqualTo(DateTime dueAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dueAt',
              lower: [],
              upper: [dueAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dueAt',
              lower: [dueAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dueAt',
              lower: [dueAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dueAt',
              lower: [],
              upper: [dueAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      dueAtGreaterThan(
    DateTime dueAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dueAt',
        lower: [dueAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      dueAtLessThan(
    DateTime dueAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dueAt',
        lower: [],
        upper: [dueAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      dueAtBetween(
    DateTime lowerDueAt,
    DateTime upperDueAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dueAt',
        lower: [lowerDueAt],
        includeLower: includeLower,
        upper: [upperDueAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      consumedEqualTo(bool consumed) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'consumed',
        value: [consumed],
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterWhereClause>
      consumedNotEqualTo(bool consumed) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'consumed',
              lower: [],
              upper: [consumed],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'consumed',
              lower: [consumed],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'consumed',
              lower: [consumed],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'consumed',
              lower: [],
              upper: [consumed],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ScheduledJobDocQueryFilter
    on QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QFilterCondition> {
  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      consumedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consumed',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      dueAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      dueAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      dueAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      dueAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      domainIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      domainIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      domainIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      domainIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      domainIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      domainIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      domainIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      domainIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'payloadRef',
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'payloadRef',
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payloadRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payloadRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payloadRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payloadRef',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'payloadRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'payloadRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payloadRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payloadRef',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payloadRef',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      payloadRefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payloadRef',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      priorityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      priorityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      typeEqualTo(
    JobType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      typeGreaterThan(
    JobType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      typeLessThan(
    JobType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      typeBetween(
    JobType lower,
    JobType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension ScheduledJobDocQueryObject
    on QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QFilterCondition> {}

extension ScheduledJobDocQueryLinks
    on QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QFilterCondition> {}

extension ScheduledJobDocQuerySortBy
    on QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QSortBy> {
  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      sortByConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumed', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      sortByConsumedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumed', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy> sortByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      sortByDueAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      sortByPayloadRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadRef', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      sortByPayloadRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadRef', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ScheduledJobDocQuerySortThenBy
    on QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QSortThenBy> {
  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumed', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByConsumedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumed', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy> thenByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByDueAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByPayloadRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadRef', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByPayloadRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadRef', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ScheduledJobDocQueryWhereDistinct
    on QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QDistinct> {
  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QDistinct>
      distinctByConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consumed');
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QDistinct> distinctByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueAt');
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QDistinct> distinctByDomainId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QDistinct>
      distinctByPayloadRef({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadRef', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QDistinct>
      distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension ScheduledJobDocQueryProperty
    on QueryBuilder<ScheduledJobDoc, ScheduledJobDoc, QQueryProperty> {
  QueryBuilder<ScheduledJobDoc, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ScheduledJobDoc, bool, QQueryOperations> consumedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consumed');
    });
  }

  QueryBuilder<ScheduledJobDoc, DateTime, QQueryOperations> dueAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueAt');
    });
  }

  QueryBuilder<ScheduledJobDoc, String, QQueryOperations> domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScheduledJobDoc, String?, QQueryOperations>
      payloadRefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadRef');
    });
  }

  QueryBuilder<ScheduledJobDoc, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<ScheduledJobDoc, JobType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettingsDocCollection on Isar {
  IsarCollection<SettingsDoc> get settingsDocs => this.collection();
}

const SettingsDocSchema = CollectionSchema(
  name: r'SettingsDoc',
  id: -5169906096891977076,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'lastLoginDay': PropertySchema(
      id: 1,
      name: r'lastLoginDay',
      type: IsarType.string,
    ),
    r'lastMonotonicRef': PropertySchema(
      id: 2,
      name: r'lastMonotonicRef',
      type: IsarType.long,
    ),
    r'lastWallClockAt': PropertySchema(
      id: 3,
      name: r'lastWallClockAt',
      type: IsarType.dateTime,
    ),
    r'loginStreakCurrent': PropertySchema(
      id: 4,
      name: r'loginStreakCurrent',
      type: IsarType.long,
    ),
    r'loginStreakMax': PropertySchema(
      id: 5,
      name: r'loginStreakMax',
      type: IsarType.long,
    ),
    r'notifications': PropertySchema(
      id: 6,
      name: r'notifications',
      type: IsarType.bool,
    ),
    r'schemaVersion': PropertySchema(
      id: 7,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'sound': PropertySchema(
      id: 8,
      name: r'sound',
      type: IsarType.bool,
    )
  },
  estimateSize: _settingsDocEstimateSize,
  serialize: _settingsDocSerialize,
  deserialize: _settingsDocDeserialize,
  deserializeProp: _settingsDocDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _settingsDocGetId,
  getLinks: _settingsDocGetLinks,
  attach: _settingsDocAttach,
  version: '3.1.0+1',
);

int _settingsDocEstimateSize(
  SettingsDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.lastLoginDay.length * 3;
  return bytesCount;
}

void _settingsDocSerialize(
  SettingsDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.lastLoginDay);
  writer.writeLong(offsets[2], object.lastMonotonicRef);
  writer.writeDateTime(offsets[3], object.lastWallClockAt);
  writer.writeLong(offsets[4], object.loginStreakCurrent);
  writer.writeLong(offsets[5], object.loginStreakMax);
  writer.writeBool(offsets[6], object.notifications);
  writer.writeLong(offsets[7], object.schemaVersion);
  writer.writeBool(offsets[8], object.sound);
}

SettingsDoc _settingsDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SettingsDoc();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.isarId = id;
  object.lastLoginDay = reader.readString(offsets[1]);
  object.lastMonotonicRef = reader.readLong(offsets[2]);
  object.lastWallClockAt = reader.readDateTime(offsets[3]);
  object.loginStreakCurrent = reader.readLong(offsets[4]);
  object.loginStreakMax = reader.readLong(offsets[5]);
  object.notifications = reader.readBool(offsets[6]);
  object.schemaVersion = reader.readLong(offsets[7]);
  object.sound = reader.readBool(offsets[8]);
  return object;
}

P _settingsDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _settingsDocGetId(SettingsDoc object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _settingsDocGetLinks(SettingsDoc object) {
  return [];
}

void _settingsDocAttach(
    IsarCollection<dynamic> col, Id id, SettingsDoc object) {
  object.isarId = id;
}

extension SettingsDocQueryWhereSort
    on QueryBuilder<SettingsDoc, SettingsDoc, QWhere> {
  QueryBuilder<SettingsDoc, SettingsDoc, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsDocQueryWhere
    on QueryBuilder<SettingsDoc, SettingsDoc, QWhereClause> {
  QueryBuilder<SettingsDoc, SettingsDoc, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SettingsDocQueryFilter
    on QueryBuilder<SettingsDoc, SettingsDoc, QFilterCondition> {
  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastLoginDayEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastLoginDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastLoginDayGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastLoginDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastLoginDayLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastLoginDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastLoginDayBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastLoginDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastLoginDayStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastLoginDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastLoginDayEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastLoginDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastLoginDayContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastLoginDay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastLoginDayMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastLoginDay',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastLoginDayIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastLoginDay',
        value: '',
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastLoginDayIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastLoginDay',
        value: '',
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastMonotonicRefEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMonotonicRef',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastMonotonicRefGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMonotonicRef',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastMonotonicRefLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMonotonicRef',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastMonotonicRefBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMonotonicRef',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastWallClockAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastWallClockAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastWallClockAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastWallClockAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastWallClockAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastWallClockAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      lastWallClockAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastWallClockAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      loginStreakCurrentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loginStreakCurrent',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      loginStreakCurrentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loginStreakCurrent',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      loginStreakCurrentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loginStreakCurrent',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      loginStreakCurrentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loginStreakCurrent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      loginStreakMaxEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loginStreakMax',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      loginStreakMaxGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loginStreakMax',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      loginStreakMaxLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loginStreakMax',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      loginStreakMaxBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loginStreakMax',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      notificationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notifications',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      schemaVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      schemaVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition>
      schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemaVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterFilterCondition> soundEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sound',
        value: value,
      ));
    });
  }
}

extension SettingsDocQueryObject
    on QueryBuilder<SettingsDoc, SettingsDoc, QFilterCondition> {}

extension SettingsDocQueryLinks
    on QueryBuilder<SettingsDoc, SettingsDoc, QFilterCondition> {}

extension SettingsDocQuerySortBy
    on QueryBuilder<SettingsDoc, SettingsDoc, QSortBy> {
  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> sortByLastLoginDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginDay', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      sortByLastLoginDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginDay', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      sortByLastMonotonicRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMonotonicRef', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      sortByLastMonotonicRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMonotonicRef', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> sortByLastWallClockAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWallClockAt', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      sortByLastWallClockAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWallClockAt', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      sortByLoginStreakCurrent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginStreakCurrent', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      sortByLoginStreakCurrentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginStreakCurrent', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> sortByLoginStreakMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginStreakMax', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      sortByLoginStreakMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginStreakMax', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> sortByNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifications', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      sortByNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifications', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> sortBySound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sound', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> sortBySoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sound', Sort.desc);
    });
  }
}

extension SettingsDocQuerySortThenBy
    on QueryBuilder<SettingsDoc, SettingsDoc, QSortThenBy> {
  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenByLastLoginDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginDay', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      thenByLastLoginDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLoginDay', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      thenByLastMonotonicRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMonotonicRef', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      thenByLastMonotonicRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMonotonicRef', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenByLastWallClockAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWallClockAt', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      thenByLastWallClockAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWallClockAt', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      thenByLoginStreakCurrent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginStreakCurrent', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      thenByLoginStreakCurrentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginStreakCurrent', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenByLoginStreakMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginStreakMax', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      thenByLoginStreakMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginStreakMax', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenByNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifications', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      thenByNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifications', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy>
      thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenBySound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sound', Sort.asc);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QAfterSortBy> thenBySoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sound', Sort.desc);
    });
  }
}

extension SettingsDocQueryWhereDistinct
    on QueryBuilder<SettingsDoc, SettingsDoc, QDistinct> {
  QueryBuilder<SettingsDoc, SettingsDoc, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QDistinct> distinctByLastLoginDay(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLoginDay', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QDistinct>
      distinctByLastMonotonicRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMonotonicRef');
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QDistinct>
      distinctByLastWallClockAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastWallClockAt');
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QDistinct>
      distinctByLoginStreakCurrent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loginStreakCurrent');
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QDistinct> distinctByLoginStreakMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loginStreakMax');
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QDistinct> distinctByNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifications');
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QDistinct> distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<SettingsDoc, SettingsDoc, QDistinct> distinctBySound() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sound');
    });
  }
}

extension SettingsDocQueryProperty
    on QueryBuilder<SettingsDoc, SettingsDoc, QQueryProperty> {
  QueryBuilder<SettingsDoc, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SettingsDoc, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SettingsDoc, String, QQueryOperations> lastLoginDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLoginDay');
    });
  }

  QueryBuilder<SettingsDoc, int, QQueryOperations> lastMonotonicRefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMonotonicRef');
    });
  }

  QueryBuilder<SettingsDoc, DateTime, QQueryOperations>
      lastWallClockAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastWallClockAt');
    });
  }

  QueryBuilder<SettingsDoc, int, QQueryOperations>
      loginStreakCurrentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loginStreakCurrent');
    });
  }

  QueryBuilder<SettingsDoc, int, QQueryOperations> loginStreakMaxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loginStreakMax');
    });
  }

  QueryBuilder<SettingsDoc, bool, QQueryOperations> notificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifications');
    });
  }

  QueryBuilder<SettingsDoc, int, QQueryOperations> schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<SettingsDoc, bool, QQueryOperations> soundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sound');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const YardSlotDocSchema = Schema(
  name: r'YardSlotDoc',
  id: 9011393893139322943,
  properties: {
    r'itemId': PropertySchema(
      id: 0,
      name: r'itemId',
      type: IsarType.string,
    ),
    r'pos': PropertySchema(
      id: 1,
      name: r'pos',
      type: IsarType.long,
    )
  },
  estimateSize: _yardSlotDocEstimateSize,
  serialize: _yardSlotDocSerialize,
  deserialize: _yardSlotDocDeserialize,
  deserializeProp: _yardSlotDocDeserializeProp,
);

int _yardSlotDocEstimateSize(
  YardSlotDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.itemId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _yardSlotDocSerialize(
  YardSlotDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.itemId);
  writer.writeLong(offsets[1], object.pos);
}

YardSlotDoc _yardSlotDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = YardSlotDoc();
  object.itemId = reader.readStringOrNull(offsets[0]);
  object.pos = reader.readLong(offsets[1]);
  return object;
}

P _yardSlotDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension YardSlotDocQueryFilter
    on QueryBuilder<YardSlotDoc, YardSlotDoc, QFilterCondition> {
  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> itemIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'itemId',
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition>
      itemIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'itemId',
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> itemIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition>
      itemIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> itemIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> itemIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition>
      itemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> itemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> itemIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> itemIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition>
      itemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition>
      itemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> posEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pos',
        value: value,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> posGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pos',
        value: value,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> posLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pos',
        value: value,
      ));
    });
  }

  QueryBuilder<YardSlotDoc, YardSlotDoc, QAfterFilterCondition> posBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension YardSlotDocQueryObject
    on QueryBuilder<YardSlotDoc, YardSlotDoc, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const FoodTrayDocSchema = Schema(
  name: r'FoodTrayDoc',
  id: 8045251619894680829,
  properties: {
    r'foodType': PropertySchema(
      id: 0,
      name: r'foodType',
      type: IsarType.string,
    ),
    r'placedAt': PropertySchema(
      id: 1,
      name: r'placedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _foodTrayDocEstimateSize,
  serialize: _foodTrayDocSerialize,
  deserialize: _foodTrayDocDeserialize,
  deserializeProp: _foodTrayDocDeserializeProp,
);

int _foodTrayDocEstimateSize(
  FoodTrayDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.foodType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _foodTrayDocSerialize(
  FoodTrayDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.foodType);
  writer.writeDateTime(offsets[1], object.placedAt);
}

FoodTrayDoc _foodTrayDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FoodTrayDoc();
  object.foodType = reader.readStringOrNull(offsets[0]);
  object.placedAt = reader.readDateTimeOrNull(offsets[1]);
  return object;
}

P _foodTrayDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FoodTrayDocQueryFilter
    on QueryBuilder<FoodTrayDoc, FoodTrayDoc, QFilterCondition> {
  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      foodTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'foodType',
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      foodTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'foodType',
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition> foodTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      foodTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      foodTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition> foodTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foodType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      foodTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      foodTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      foodTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'foodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition> foodTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'foodType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      foodTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodType',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      foodTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'foodType',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      placedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'placedAt',
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      placedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'placedAt',
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition> placedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'placedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      placedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'placedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition>
      placedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'placedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodTrayDoc, FoodTrayDoc, QAfterFilterCondition> placedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'placedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FoodTrayDocQueryObject
    on QueryBuilder<FoodTrayDoc, FoodTrayDoc, QFilterCondition> {}
