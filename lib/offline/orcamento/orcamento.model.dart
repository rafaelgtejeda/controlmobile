import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';
import 'package:http/http.dart' as http;

// part 'orcamento.model.g.dart';

const tableOrcamento = SqfEntityTable(
  tableName: 'orcamento',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  useSoftDeleting: true,
  modelName: null,
  fields: [
    SqfEntityField('apiId', DbType.integer, defaultValue: 0),
    SqfEntityField('empresaId', DbType.integer),
    SqfEntityField('clienteId', DbType.integer),
    SqfEntityField('vendedorId', DbType.integer),
    SqfEntityField('observacao', DbType.text),
    SqfEntityField('pessoa', DbType.integer),

    SqfEntityField('email', DbType.text),
    SqfEntityField('ddiTelefone', DbType.text),
    SqfEntityField('dddTelefone', DbType.text),
    SqfEntityField('telefone', DbType.text),
    SqfEntityField('ddiCelular', DbType.text),
    SqfEntityField('dddCelular', DbType.text),
    SqfEntityField('celular', DbType.text),

    SqfEntityField('cep', DbType.text),
    SqfEntityField('endereco', DbType.text),
    SqfEntityField('numero', DbType.text),
    SqfEntityField('bairro', DbType.text),
    SqfEntityField('complemento', DbType.text),
    SqfEntityField('cidade', DbType.text),
    SqfEntityField('uf', DbType.text),
    
    SqfEntityField('dataCadastro', DbType.text),
    SqfEntityField('dataAtualizacao', DbType.text),
    SqfEntityField('dataDeletado', DbType.text),
    SqfEntityField('isSelected', DbType.bool, defaultValue: false),
  ]
);
