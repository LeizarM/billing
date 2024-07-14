// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetItemCollection on Isar {
  IsarCollection<Item> get items => this.collection();
}

const ItemSchema = CollectionSchema(
  name: r'Item',
  id: 7900997316587104717,
  properties: {
    r'codArticulo': PropertySchema(
      id: 0,
      name: r'codArticulo',
      type: IsarType.string,
    ),
    r'codCiudad': PropertySchema(
      id: 1,
      name: r'codCiudad',
      type: IsarType.long,
    ),
    r'codGrpFamiliaSap': PropertySchema(
      id: 2,
      name: r'codGrpFamiliaSap',
      type: IsarType.string,
    ),
    r'codigoFamilia': PropertySchema(
      id: 3,
      name: r'codigoFamilia',
      type: IsarType.string,
    ),
    r'datoArt': PropertySchema(
      id: 4,
      name: r'datoArt',
      type: IsarType.string,
    ),
    r'db': PropertySchema(
      id: 5,
      name: r'db',
      type: IsarType.string,
    ),
    r'disponible': PropertySchema(
      id: 6,
      name: r'disponible',
      type: IsarType.long,
    ),
    r'listaPrecio': PropertySchema(
      id: 7,
      name: r'listaPrecio',
      type: IsarType.long,
    ),
    r'moneda': PropertySchema(
      id: 8,
      name: r'moneda',
      type: IsarType.string,
    ),
    r'precio': PropertySchema(
      id: 9,
      name: r'precio',
      type: IsarType.double,
    ),
    r'ruta': PropertySchema(
      id: 10,
      name: r'ruta',
      type: IsarType.string,
    ),
    r'unidadMedida': PropertySchema(
      id: 11,
      name: r'unidadMedida',
      type: IsarType.string,
    )
  },
  estimateSize: _itemEstimateSize,
  serialize: _itemSerialize,
  deserialize: _itemDeserialize,
  deserializeProp: _itemDeserializeProp,
  idName: r'id',
  indexes: {
    r'codArticulo': IndexSchema(
      id: 6346922464106636376,
      name: r'codArticulo',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'codArticulo',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _itemGetId,
  getLinks: _itemGetLinks,
  attach: _itemAttach,
  version: '3.1.0+1',
);

int _itemEstimateSize(
  Item object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.codArticulo.length * 3;
  bytesCount += 3 + object.codGrpFamiliaSap.length * 3;
  bytesCount += 3 + object.codigoFamilia.length * 3;
  bytesCount += 3 + object.datoArt.length * 3;
  bytesCount += 3 + object.db.length * 3;
  bytesCount += 3 + object.moneda.length * 3;
  bytesCount += 3 + object.ruta.length * 3;
  bytesCount += 3 + object.unidadMedida.length * 3;
  return bytesCount;
}

void _itemSerialize(
  Item object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.codArticulo);
  writer.writeLong(offsets[1], object.codCiudad);
  writer.writeString(offsets[2], object.codGrpFamiliaSap);
  writer.writeString(offsets[3], object.codigoFamilia);
  writer.writeString(offsets[4], object.datoArt);
  writer.writeString(offsets[5], object.db);
  writer.writeLong(offsets[6], object.disponible);
  writer.writeLong(offsets[7], object.listaPrecio);
  writer.writeString(offsets[8], object.moneda);
  writer.writeDouble(offsets[9], object.precio);
  writer.writeString(offsets[10], object.ruta);
  writer.writeString(offsets[11], object.unidadMedida);
}

Item _itemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Item();
  object.codArticulo = reader.readString(offsets[0]);
  object.codCiudad = reader.readLong(offsets[1]);
  object.codGrpFamiliaSap = reader.readString(offsets[2]);
  object.codigoFamilia = reader.readString(offsets[3]);
  object.datoArt = reader.readString(offsets[4]);
  object.db = reader.readString(offsets[5]);
  object.disponible = reader.readLong(offsets[6]);
  object.id = id;
  object.listaPrecio = reader.readLong(offsets[7]);
  object.moneda = reader.readString(offsets[8]);
  object.precio = reader.readDouble(offsets[9]);
  object.ruta = reader.readString(offsets[10]);
  object.unidadMedida = reader.readString(offsets[11]);
  return object;
}

P _itemDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _itemGetId(Item object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _itemGetLinks(Item object) {
  return [];
}

void _itemAttach(IsarCollection<dynamic> col, Id id, Item object) {
  object.id = id;
}

extension ItemQueryWhereSort on QueryBuilder<Item, Item, QWhere> {
  QueryBuilder<Item, Item, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Item, Item, QAfterWhere> anyCodArticulo() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'codArticulo'),
      );
    });
  }
}

extension ItemQueryWhere on QueryBuilder<Item, Item, QWhereClause> {
  QueryBuilder<Item, Item, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> codArticuloEqualTo(
      String codArticulo) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'codArticulo',
        value: [codArticulo],
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> codArticuloNotEqualTo(
      String codArticulo) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codArticulo',
              lower: [],
              upper: [codArticulo],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codArticulo',
              lower: [codArticulo],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codArticulo',
              lower: [codArticulo],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codArticulo',
              lower: [],
              upper: [codArticulo],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> codArticuloGreaterThan(
    String codArticulo, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'codArticulo',
        lower: [codArticulo],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> codArticuloLessThan(
    String codArticulo, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'codArticulo',
        lower: [],
        upper: [codArticulo],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> codArticuloBetween(
    String lowerCodArticulo,
    String upperCodArticulo, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'codArticulo',
        lower: [lowerCodArticulo],
        includeLower: includeLower,
        upper: [upperCodArticulo],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> codArticuloStartsWith(
      String CodArticuloPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'codArticulo',
        lower: [CodArticuloPrefix],
        upper: ['$CodArticuloPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> codArticuloIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'codArticulo',
        value: [''],
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterWhereClause> codArticuloIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'codArticulo',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'codArticulo',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'codArticulo',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'codArticulo',
              upper: [''],
            ));
      }
    });
  }
}

extension ItemQueryFilter on QueryBuilder<Item, Item, QFilterCondition> {
  QueryBuilder<Item, Item, QAfterFilterCondition> codArticuloEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codArticulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codArticuloGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codArticulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codArticuloLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codArticulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codArticuloBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codArticulo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codArticuloStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codArticulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codArticuloEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codArticulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codArticuloContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codArticulo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codArticuloMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codArticulo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codArticuloIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codArticulo',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codArticuloIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codArticulo',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codCiudadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codCiudad',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codCiudadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codCiudad',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codCiudadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codCiudad',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codCiudadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codCiudad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codGrpFamiliaSapEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codGrpFamiliaSap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codGrpFamiliaSapGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codGrpFamiliaSap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codGrpFamiliaSapLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codGrpFamiliaSap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codGrpFamiliaSapBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codGrpFamiliaSap',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codGrpFamiliaSapStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codGrpFamiliaSap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codGrpFamiliaSapEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codGrpFamiliaSap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codGrpFamiliaSapContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codGrpFamiliaSap',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codGrpFamiliaSapMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codGrpFamiliaSap',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codGrpFamiliaSapIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codGrpFamiliaSap',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codGrpFamiliaSapIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codGrpFamiliaSap',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codigoFamiliaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoFamilia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codigoFamiliaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigoFamilia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codigoFamiliaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigoFamilia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codigoFamiliaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigoFamilia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codigoFamiliaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigoFamilia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codigoFamiliaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigoFamilia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codigoFamiliaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigoFamilia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codigoFamiliaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigoFamilia',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codigoFamiliaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoFamilia',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> codigoFamiliaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigoFamilia',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> datoArtEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'datoArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> datoArtGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'datoArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> datoArtLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'datoArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> datoArtBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'datoArt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> datoArtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'datoArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> datoArtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'datoArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> datoArtContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'datoArt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> datoArtMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'datoArt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> datoArtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'datoArt',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> datoArtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'datoArt',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> dbEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'db',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> dbGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'db',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> dbLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'db',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> dbBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'db',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> dbStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'db',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> dbEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'db',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> dbContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'db',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> dbMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'db',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> dbIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'db',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> dbIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'db',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> disponibleEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disponible',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> disponibleGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'disponible',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> disponibleLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'disponible',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> disponibleBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'disponible',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> listaPrecioEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'listaPrecio',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> listaPrecioGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'listaPrecio',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> listaPrecioLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'listaPrecio',
        value: value,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> listaPrecioBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'listaPrecio',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> monedaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> monedaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> monedaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> monedaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moneda',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> monedaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> monedaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> monedaContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> monedaMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'moneda',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> monedaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moneda',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> monedaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'moneda',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> precioEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precio',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> precioGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precio',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> precioLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precio',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> precioBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precio',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> rutaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ruta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> rutaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ruta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> rutaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ruta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> rutaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ruta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> rutaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ruta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> rutaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ruta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> rutaContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ruta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> rutaMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ruta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> rutaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ruta',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> rutaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ruta',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> unidadMedidaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unidadMedida',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> unidadMedidaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unidadMedida',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> unidadMedidaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unidadMedida',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> unidadMedidaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unidadMedida',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> unidadMedidaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unidadMedida',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> unidadMedidaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unidadMedida',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> unidadMedidaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unidadMedida',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> unidadMedidaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unidadMedida',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> unidadMedidaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unidadMedida',
        value: '',
      ));
    });
  }

  QueryBuilder<Item, Item, QAfterFilterCondition> unidadMedidaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unidadMedida',
        value: '',
      ));
    });
  }
}

extension ItemQueryObject on QueryBuilder<Item, Item, QFilterCondition> {}

extension ItemQueryLinks on QueryBuilder<Item, Item, QFilterCondition> {}

extension ItemQuerySortBy on QueryBuilder<Item, Item, QSortBy> {
  QueryBuilder<Item, Item, QAfterSortBy> sortByCodArticulo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codArticulo', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByCodArticuloDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codArticulo', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByCodCiudad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codCiudad', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByCodCiudadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codCiudad', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByCodGrpFamiliaSap() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codGrpFamiliaSap', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByCodGrpFamiliaSapDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codGrpFamiliaSap', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByCodigoFamilia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoFamilia', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByCodigoFamiliaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoFamilia', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByDatoArt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datoArt', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByDatoArtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datoArt', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByDb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'db', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByDbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'db', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByDisponible() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disponible', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByDisponibleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disponible', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByListaPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listaPrecio', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByListaPrecioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listaPrecio', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByMoneda() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByMonedaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precio', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByPrecioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precio', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByRuta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruta', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByRutaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruta', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByUnidadMedida() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadMedida', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> sortByUnidadMedidaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadMedida', Sort.desc);
    });
  }
}

extension ItemQuerySortThenBy on QueryBuilder<Item, Item, QSortThenBy> {
  QueryBuilder<Item, Item, QAfterSortBy> thenByCodArticulo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codArticulo', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByCodArticuloDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codArticulo', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByCodCiudad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codCiudad', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByCodCiudadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codCiudad', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByCodGrpFamiliaSap() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codGrpFamiliaSap', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByCodGrpFamiliaSapDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codGrpFamiliaSap', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByCodigoFamilia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoFamilia', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByCodigoFamiliaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoFamilia', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByDatoArt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datoArt', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByDatoArtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'datoArt', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByDb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'db', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByDbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'db', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByDisponible() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disponible', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByDisponibleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disponible', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByListaPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listaPrecio', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByListaPrecioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listaPrecio', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByMoneda() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByMonedaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precio', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByPrecioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precio', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByRuta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruta', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByRutaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruta', Sort.desc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByUnidadMedida() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadMedida', Sort.asc);
    });
  }

  QueryBuilder<Item, Item, QAfterSortBy> thenByUnidadMedidaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadMedida', Sort.desc);
    });
  }
}

extension ItemQueryWhereDistinct on QueryBuilder<Item, Item, QDistinct> {
  QueryBuilder<Item, Item, QDistinct> distinctByCodArticulo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codArticulo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByCodCiudad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codCiudad');
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByCodGrpFamiliaSap(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codGrpFamiliaSap',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByCodigoFamilia(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigoFamilia',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByDatoArt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'datoArt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByDb(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'db', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByDisponible() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disponible');
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByListaPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'listaPrecio');
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByMoneda(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moneda', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precio');
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByRuta(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ruta', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Item, Item, QDistinct> distinctByUnidadMedida(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unidadMedida', caseSensitive: caseSensitive);
    });
  }
}

extension ItemQueryProperty on QueryBuilder<Item, Item, QQueryProperty> {
  QueryBuilder<Item, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Item, String, QQueryOperations> codArticuloProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codArticulo');
    });
  }

  QueryBuilder<Item, int, QQueryOperations> codCiudadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codCiudad');
    });
  }

  QueryBuilder<Item, String, QQueryOperations> codGrpFamiliaSapProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codGrpFamiliaSap');
    });
  }

  QueryBuilder<Item, String, QQueryOperations> codigoFamiliaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigoFamilia');
    });
  }

  QueryBuilder<Item, String, QQueryOperations> datoArtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'datoArt');
    });
  }

  QueryBuilder<Item, String, QQueryOperations> dbProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'db');
    });
  }

  QueryBuilder<Item, int, QQueryOperations> disponibleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disponible');
    });
  }

  QueryBuilder<Item, int, QQueryOperations> listaPrecioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'listaPrecio');
    });
  }

  QueryBuilder<Item, String, QQueryOperations> monedaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moneda');
    });
  }

  QueryBuilder<Item, double, QQueryOperations> precioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precio');
    });
  }

  QueryBuilder<Item, String, QQueryOperations> rutaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ruta');
    });
  }

  QueryBuilder<Item, String, QQueryOperations> unidadMedidaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unidadMedida');
    });
  }
}
