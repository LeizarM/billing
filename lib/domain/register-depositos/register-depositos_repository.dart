

import 'dart:io';

import 'package:billing/domain/register-depositos/BancoXCuenta.dart';
import 'package:billing/domain/register-depositos/DepositoCheque.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';

abstract class DepositoRepository {
  Future<List<Empresa>> getEmpresas();
  Future<List<SocioNegocio>> getSociosNegocio(int codEmpresa);
  Future<List<BancoXCuenta>> getBancos( int codEmpresa );
  Future<bool> registrarDeposito(DepositoCheque deposito, File imagen);
}