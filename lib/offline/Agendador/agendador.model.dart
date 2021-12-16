import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';
import 'package:http/http.dart' as http;

// part 'cliente.model.g.dart';

const tableAgendador = SqfEntityTable(
  tableName: 'agendador',
  useSoftDeleting: true,
  modelName: null,
  fields: [
    SqfEntityField('id', DbType.integer, isPrimaryKeyField: true),
    SqfEntityField('operacaoId', DbType.integer, defaultValue: 0),
    SqfEntityField('dataCron', DbType.text)   
  ]
);