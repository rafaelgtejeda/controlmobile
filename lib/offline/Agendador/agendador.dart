import 'package:erp/offline/orm_base.dart';
import 'package:erp/offline/controlador/controlador.dart';
import 'package:cron/cron.dart';
class AgendadorCron{

   var cron = new Cron();

   adicionaAgendador() async {
     
     int existe = await Agendador().select().toCount();

     print('Agendador: $existe');

     if(existe == 0) {
        Agendador.withFields(1, "1", false).save();
        print('Adicionou agendador default');
     }

   }

   initCron() async {

      List<Agendador> agendador = await Agendador().select().id.equals(1).toList();

      cron.schedule(new Schedule.parse('*/${agendador[0].dataCron} * * * *'), () async {

        print('cron a cada ${agendador[0].dataCron} minutos.');
        Controlador().verificaOffline();

      });

   }
 
}