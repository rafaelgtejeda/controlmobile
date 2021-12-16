import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';
import 'package:http/http.dart' as http;

// part 'cliente.model.g.dart';

const tableControle = SqfEntityTable(
  tableName: 'controle',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_unique,
  useSoftDeleting: true,
  modelName: null,
  fields: [
    SqfEntityField('operacaoId', DbType.integer, defaultValue: 0),
    SqfEntityField('dataControle', DbType.text),
  ]
);