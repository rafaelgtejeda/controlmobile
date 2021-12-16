import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';
import 'package:http/http.dart' as http;

// part 'cliente.model.g.dart';

const tableEmpresa = SqfEntityTable(
  tableName: 'empresa',
  useSoftDeleting: true,
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  modelName: null,
  fields: [
    SqfEntityField('apiId', DbType.integer, defaultValue: 0),
    SqfEntityField('nome', DbType.text),
    SqfEntityField('nomeFantasia', DbType.text),
    SqfEntityField('ondeProcuraContato', DbType.integer),
    SqfEntityField('ondeProcuraProduto', DbType.integer),
    
    SqfEntityField('dataCadastro', DbType.text),
    SqfEntityField('dataAtualizacao', DbType.text),
    SqfEntityField('dataDeletado', DbType.text),
    SqfEntityField('isSelected', DbType.bool, defaultValue: false),
  ]
);
