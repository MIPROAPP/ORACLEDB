CREATE OR REPLACE PACKAGE cz_mi.SKMI AS

  PROCEDURE SOLICITUD(P_IN    IN     CLOB,
                      P_OUT      OUT CLOB,
                      P_ERROR IN OUT VARCHAR2);

  PROCEDURE CATALOGOS(P_OUT OUT CLOB, P_ERROR IN OUT VARCHAR2);

  PROCEDURE CONSULTA_SOLICITUD(P_IN    IN     CLOB,
                               P_OUT      OUT CLOB,
                               P_ERROR IN OUT VARCHAR2);

END SKMI;
/
