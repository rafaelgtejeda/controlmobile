import 'dart:convert';
import 'package:erp/offline/clientes/cliente.model.dart';
import 'package:erp/offline/controlador/controlador.model.dart';
import 'package:erp/offline/empresa/empresa.model.dart';
import 'package:erp/offline/orcamento/orcamento.model.dart';
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';
import 'package:http/http.dart' as http;

import 'Agendador/agendador.model.dart';

part 'orm_base.g.dart';

@SqfEntityBuilder(offlineDbModel)
const offlineDbModel = SqfEntityModel(
    modelName: 'OfflineDbModel', // optional
    databaseName: 'offlineORM.db',
    databaseTables: [tableCliente, tableOrcamento, tableEmpresa, tableControle, tableAgendador],
    // sequences: [seqIdentity],
    bundledDatabasePath: null
);
