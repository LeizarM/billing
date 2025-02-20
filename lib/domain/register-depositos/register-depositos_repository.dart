

import 'dart:io';

import 'package:billing/domain/register-depositos/ChBanco.dart';
import 'package:billing/domain/register-depositos/DepositoCheque.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';

abstract class DepositoRepository {
  Future<List<Empresa>> getEmpresas();
  Future<List<SocioNegocio>> getSociosNegocio(int codEmpresa);
  Future<List<ChBanco>> getBancos();
  Future<bool> registrarDeposito(DepositoCheque deposito, File imagen);
}