-- La resolucion logica del juego -- el UNICO lugar donde se define.
-- conf.lua la lee para dimensionar la ventana real; los sistemas de UI
-- la leen para centrar paneles y textos sobre un lienzo fijo, porque
-- este juego (McLaren's, la seleccion de challenge, la "batalla" con
-- cada chica) es una sucesion de pantallas estaticas, sin camara que
-- se mueva: 640x400 le da a cada escena el mismo marco de referencia.
return { w = 640, h = 400 }
