// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String aboutMapiahDialogMapiahVersion(Object version) {
    return 'Versão $version';
  }

  @override
  String get aboutMapiahDialogWindowTitle => 'Sobre o Mapiah';

  @override
  String get appTitle => 'Mapiah';

  @override
  String get close => 'Fechar';

  @override
  String get initialPageAboutMapiahDialog => 'Sobre o Mapiah';

  @override
  String get initialPageLanguage => 'Idioma';

  @override
  String get initialPageOpenFile => 'Abrir arquivo (Ctrl+O)';

  @override
  String get initialPagePresentation => 'Mapiah: uma interface gráfica amigável para mapeamento de cavernas com Therion';

  @override
  String get fileEditWindowWindowTitle => 'Edição de arquivo';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(
      language,
      {
        'sys': 'Sistema',
        'en': 'English',
        'pt': 'Português',
        'other': 'Desconhecido',
      },
    );
    return '$_temp0';
  }

  @override
  String get mpAltitudeInvalidValueErrorMessage => 'Altitude inválida';

  @override
  String get mpAuthorInvalidValueErrorMessage => 'Data/intervalo de data e nome de autor válidos';

  @override
  String get mpButtonCancel => 'Cancelar';

  @override
  String get mpButtonOK => 'OK';

  @override
  String get mpChoiceSet => 'Definido';

  @override
  String get mpChoiceUnset => 'Não definido';

  @override
  String get mpCommandDescriptionAddElements => 'Adicionar elementos';

  @override
  String get mpCommandDescriptionAddLine => 'Adicionar linha';

  @override
  String get mpCommandDescriptionAddLineSegment => 'Adicionar segmento de linha';

  @override
  String get mpCommandDescriptionAddPoint => 'Adicionar ponto';

  @override
  String get mpCommandDescriptionEditAreasType => 'Editar tipo de áreas';

  @override
  String get mpCommandDescriptionEditAreaType => 'Editar tipo de área';

  @override
  String get mpCommandDescriptionEditBezierCurve => 'Editar curva Bézier';

  @override
  String get mpCommandDescriptionEditLine => 'Editar linha';

  @override
  String get mpCommandDescriptionEditLineSegment => 'Editar segmento de linha';

  @override
  String get mpCommandDescriptionEditLinesType => 'Editar tipo de linhas';

  @override
  String get mpCommandDescriptionEditLineType => 'Editar tipo de linha';

  @override
  String get mpCommandDescriptionEditPointsType => 'Editar tipo de pontos';

  @override
  String get mpCommandDescriptionEditPointType => 'Editar tipo de ponto';

  @override
  String get mpCommandDescriptionMoveBezierLineSegment => 'Mover segmento de linha Bézier';

  @override
  String get mpCommandDescriptionMoveElements => 'Mover elementos';

  @override
  String get mpCommandDescriptionMoveLine => 'Mover linha';

  @override
  String get mpCommandDescriptionMoveLineSegments => 'Mover segmentos de linha';

  @override
  String get mpCommandDescriptionMovePoint => 'Mover ponto';

  @override
  String get mpCommandDescriptionMoveStraightLineSegment => 'Mover segmento de linha reta';

  @override
  String get mpCommandDescriptionMultipleElements => 'Editar vários elementos';

  @override
  String get mpCommandDescriptionRemoveElements => 'Apagar elementos';

  @override
  String get mpCommandDescriptionRemoveLine => 'Apagar linha';

  @override
  String get mpCommandDescriptionRemoveLineSegment => 'Apagar segmento de linha';

  @override
  String get mpCommandDescriptionRemoveOptionFromElement => 'Remover opção';

  @override
  String get mpCommandDescriptionRemoveOptionFromElements => 'Remover opção de diversos elementos';

  @override
  String get mpCommandDescriptionRemovePoint => 'Apagar ponto';

  @override
  String get mpCommandDescriptionSetOptionToElement => 'Definir opção';

  @override
  String get mpCommandDescriptionSetOptionToElements => 'Definir opção para diversos elementos';

  @override
  String get mpContextInvalidValueErrorMessage => 'Ambos os campos são obrigatórios';

  @override
  String get mpCopyrightInvalidMessageErrorMessage => 'Mensagem de direitos autorais inválido';

  @override
  String get mpCopyrightMessageLabel => 'Direitos autorais';

  @override
  String mpCSEPSGESRILabel(Object csOption) {
    return 'Identificador $csOption (1-99999)';
  }

  @override
  String get mpCSETRSLabel => 'Identificador opcional ETRS (1-99999)';

  @override
  String get mpCSInvalidValueErrorMessage => 'Valor inválido';

  @override
  String get mpCSForOutputLabel => 'Para saída';

  @override
  String get mpCSOSGBMajorLabel => 'OSGB principal';

  @override
  String get mpCSOSGBMinorLabel => 'OSGB menor';

  @override
  String get mpCSUTMZoneNumberLabel => 'Número da zona UTM (1-60)';

  @override
  String get mpCSUTMNorthLabel => 'Norte';

  @override
  String get mpCSUTMSouthLabel => 'Sul';

  @override
  String get mpDateIntervalEndDateHint => 'AAAA[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]';

  @override
  String get mpDateIntervalEndDateLabel => 'Data de término';

  @override
  String get mpDateIntervalIntervalLabel => 'Intervalo';

  @override
  String get mpDateIntervalInvalidEndDateFormatErrorMessage => 'Data de término inválida';

  @override
  String get mpDateIntervalInvalidStartDateFormatErrorMessage => 'Data de início inválida';

  @override
  String get mpDateIntervalSingleDateLabel => 'Data';

  @override
  String get mpDateIntervalStartDateHint => 'AAAA[.MM[.DD[@HH[:MM[:SS[.SS]]]]]] ou \'-\'';

  @override
  String get mpDateIntervalStartDateLabel => 'Data de início';

  @override
  String get mpDateValueInvalidValueErrorMessage => 'Data ou intervalo inválidos';

  @override
  String get mpDimensionsAboveLabel => 'Acima';

  @override
  String get mpDimensionsBelowLabel => 'Abaixo';

  @override
  String get mpDimensionsInvalidValueErrorMessage => 'Valor inválida';

  @override
  String get mpDistInvalidValueErrorMessage => 'Distância inválida';

  @override
  String get mpDistDistanceLabel => 'Distância';

  @override
  String get mpExploredLengthLabel => 'Extensão';

  @override
  String get mpExtendStationLabel => 'Base';

  @override
  String get mpIDIDLabel => 'ID';

  @override
  String get mpIDInvalidValueErrorMessage => 'ID inválido: deve ser uma sequência de caracteres A-Z, a-z, 0-9 e _-/ (não começando com ‘-’).';

  @override
  String get mpIDNonUniqueValueErrorMessage => 'IDs devem ser únicos.';

  @override
  String get mpLengthUnitCentimeter => 'centímetro';

  @override
  String get mpLengthUnitCentimeterAbbreviation => 'cm';

  @override
  String get mpLengthUnitFoot => 'pé';

  @override
  String get mpLengthUnitFootAbbreviation => 'ft';

  @override
  String get mpLengthUnitInch => 'polegada';

  @override
  String get mpLengthUnitInchAbbreviation => 'in';

  @override
  String get mpLengthUnitMeter => 'metro';

  @override
  String get mpLengthUnitMeterAbbreviation => 'm';

  @override
  String get mpLengthUnitYard => 'jarda';

  @override
  String get mpLengthUnitYardAbbreviation => 'yd';

  @override
  String get mpLineHeightInvalidValueErrorMessage => 'Altura inválida';

  @override
  String get mpLineHeightHeightLabel => 'Altura';

  @override
  String get mpNamedScaleTiny => 'Minúsculo';

  @override
  String get mpNamedScaleSmall => 'Pequeno';

  @override
  String get mpNamedScaleNormal => 'Normal';

  @override
  String get mpNamedScaleLarge => 'Grande';

  @override
  String get mpNamedScaleHuge => 'Enorme';

  @override
  String get mpPersonNameInvalidFormatErrorMessage => 'Nome inválido';

  @override
  String get mpPersonNameLabel => 'Nome';

  @override
  String get mpPersonNameHint => '\'PrimeiroNome Sobrenome\' ou \'PrimeirosNomes/Sobrenomes\'';

  @override
  String get mpPLATypeAll => 'Todos';

  @override
  String get mpPLATypeAreaTitle => 'Tipos de área';

  @override
  String get mpPLATypeCurrent => 'Atual';

  @override
  String get mpPLATypeDropdownSelectATypeLabel => 'Selecione um tipo';

  @override
  String get mpPLATypeLastUsed => 'Últimos usados';

  @override
  String get mpPLATypeLineTitle => 'Tipos de linha';

  @override
  String get mpPLATypeMostUsed => 'Mais usados';

  @override
  String get mpPLATypePointTitle => 'Tipos de ponto';

  @override
  String get mpPLScaleCommandOptionNamed => 'Pré-definidos';

  @override
  String get mpPLScaleCommandOptionNumeric => 'Numérico';

  @override
  String get mpLPScaleNumericLabel => 'Tamanho';

  @override
  String get mpOptionsEditTitle => 'Opções';

  @override
  String get parsingErrors => 'Erros na interpretação do arquivo';

  @override
  String get th2FileEditPageAddArea => 'Criar área (A)';

  @override
  String th2FileEditPageAddAreaStatusBarMessage(Object type) {
    return 'Clique para criar uma área do tipo $type';
  }

  @override
  String get th2FileEditPageAddElementOptions => 'Criar elemento';

  @override
  String get th2FileEditPageAddLine => 'Criar linha (L)';

  @override
  String th2FileEditPageAddLineStatusBarMessage(Object type) {
    return 'Clique para criar uma linha do tipo $type';
  }

  @override
  String get th2FileEditPageAddPoint => 'Criar ponto (P)';

  @override
  String th2FileEditPageAddPointStatusBarMessage(Object type) {
    return 'Clique para criar um ponto do tipo $type';
  }

  @override
  String get th2FileEditPageChangeActiveScrapTool => 'Alterar croqui ativo (Alt+C)';

  @override
  String get th2FileEditPageChangeActiveScrapTitle => 'Alterar croqui ativo';

  @override
  String get th2FileEditPageEmptySelectionStatusBarMessage => 'Nenhum elemento selecionado';

  @override
  String th2FileEditPageLoadingFile(Object filename) {
    return 'Lendo arquivo $filename ...';
  }

  @override
  String get th2FileEditPageNodeEditTool => 'Editar nós (N)';

  @override
  String th2FileEditPageNonEmptySelectionOnlyLinesStatusBarMessage(Object amount) {
    return '$amount linha(s) selecionadas';
  }

  @override
  String th2FileEditPageNonEmptySelectionOnlyPointsStatusBarMessage(Object amount) {
    return '$amount pontos(s) selecionados';
  }

  @override
  String th2FileEditPageNonEmptySelectionPointsAndLinesStatusBarMessage(Object pointsAmount, Object linesAmount) {
    return '$pointsAmount pontos(s) e $linesAmount linhas(s) selecionados';
  }

  @override
  String get th2FileEditPageNoUndoAvailable => 'Nenhuma ação para desfazer';

  @override
  String get th2FileEditPageNoRedoAvailable => 'Nenhuma ação para refazer';

  @override
  String get th2FileEditPageOptionTool => 'Opções (O)';

  @override
  String get th2FileEditPagePanTool => 'Mover ponto de vista';

  @override
  String get th2FileEditPageRemoveButton => 'Apagar (Del)';

  @override
  String get th2FileEditPageSave => 'Salvar (Ctrl+S)';

  @override
  String get th2FileEditPageSaveAs => 'Salvar como (Shift+Ctrl+S)';

  @override
  String th2FileEditPageRedo(Object redoDescription) {
    return 'Refazer \'$redoDescription\' (Ctrl+Y)';
  }

  @override
  String get th2FileEditPageSelectTool => 'Selecionar (C)';

  @override
  String th2FileEditPageUndo(Object undoDescription) {
    return 'Desfazer \'$undoDescription\' (Ctrl+Z)';
  }

  @override
  String get th2FileEditPageZoomIn => 'Aproximar (+)';

  @override
  String get th2FileEditPageZoomOneToOne => 'Mostrar 1:1 (1)';

  @override
  String get th2FileEditPageZoomOptions => 'Opções de zoom';

  @override
  String get th2FileEditPageZoomOut => 'Afastar (-)';

  @override
  String get th2FileEditPageZoomOutFile => 'Mostrar arquivo (3)';

  @override
  String get th2FileEditPageZoomOutScrap => 'Mostrar croqui (4)';

  @override
  String get th2FileEditPageZoomToSelection => 'Mostrar seleção (2)';

  @override
  String get th2FilePickSelectTH2File => 'Selecione um arquivo TH2';

  @override
  String get thAreaBedrock => 'Rocha matriz';

  @override
  String get thAreaBlocks => 'Blocos';

  @override
  String get thAreaClay => 'Argila';

  @override
  String get thAreaDebris => 'Detritos';

  @override
  String get thAreaFlowstone => 'Travertino';

  @override
  String get thAreaIce => 'Gelo';

  @override
  String get thAreaMoonmilk => 'Leite de Lua';

  @override
  String get thAreaMudcrack => 'Rachadura de Lama';

  @override
  String get thAreaPebbles => 'Seixos';

  @override
  String get thAreaPillar => 'Pilar';

  @override
  String get thAreaPillars => 'Pilares';

  @override
  String get thAreaPillarsWithCurtains => 'Pilares com Cortinas';

  @override
  String get thAreaPillarWithCurtains => 'Pilar com Cortinas';

  @override
  String get thAreaSand => 'Areia';

  @override
  String get thAreaSnow => 'Neve';

  @override
  String get thAreaStalactite => 'Estalactite';

  @override
  String get thAreaStalactiteStalagmite => 'Estalactite e Estalagmite';

  @override
  String get thAreaStalagmite => 'Estalagmite';

  @override
  String get thAreaSump => 'Sifão';

  @override
  String get thAreaU => 'Usuário';

  @override
  String get thAreaWater => 'Água';

  @override
  String get thElementArea => 'Área';

  @override
  String get thElementAreaBorderTHID => 'ID de borda de área';

  @override
  String get thElementBezierCurveLineSegment => 'Segmento de linha Bézier';

  @override
  String get thElementComment => 'Comentário';

  @override
  String get thElementEmptyLine => 'Linha vazia';

  @override
  String get thElementEncoding => 'Codificação';

  @override
  String get thElementEndArea => 'Fim de área';

  @override
  String get thElementEndComment => 'Fim de comentário';

  @override
  String get thElementEndLine => 'Fim de linha';

  @override
  String get thElementEndScrap => 'Fim de croqui';

  @override
  String get thElementLine => 'Linha';

  @override
  String get thElementLineSegment => 'Segmento de linha';

  @override
  String get thElementMultilineCommentContent => 'Conteúdo de comentário multilinha';

  @override
  String get thElementMultilineComment => 'Comentário multilinha';

  @override
  String get thElementPoint => 'Ponto';

  @override
  String get thElementScrap => 'Croqui';

  @override
  String get thElementStraightLineSegment => 'Segmento de linha reta';

  @override
  String get thElementUnrecognized => 'Elemento não reconhecido';

  @override
  String get thElementXTherionConfig => 'Configuração XTherion';

  @override
  String get thPointAirDraught => 'Corrente de ar';

  @override
  String get thPointAltar => 'Altar';

  @override
  String get thPointAltitude => 'Altitude';

  @override
  String get thPointAnastomosis => 'Anastomose';

  @override
  String get thPointAnchor => 'Âncora';

  @override
  String get thPointAragonite => 'Aragonita';

  @override
  String get thPointArcheoExcavation => 'Escavação arqueológica';

  @override
  String get thPointArcheoMaterial => 'Material arqueológico';

  @override
  String get thPointAudio => 'Áudio';

  @override
  String get thPointBat => 'Morcego';

  @override
  String get thPointBedrock => 'Rocha matriz';

  @override
  String get thPointBlocks => 'Blocos';

  @override
  String get thPointBones => 'Ossos';

  @override
  String get thPointBreakdownChoke => 'Bloqueio de desmoronamento';

  @override
  String get thPointBridge => 'Ponte';

  @override
  String get thPointCamp => 'Acampamento';

  @override
  String get thPointCavePearl => 'Pérola de caverna';

  @override
  String get thPointClay => 'Argila';

  @override
  String get thPointClayChoke => 'Bloqueio de argila';

  @override
  String get thPointClayTree => 'Árvore de argila';

  @override
  String get thPointContinuation => 'Continuação';

  @override
  String get thPointCrystal => 'Cristal';

  @override
  String get thPointCurtain => 'Cortina';

  @override
  String get thPointCurtains => 'Cortinas';

  @override
  String get thPointDanger => 'Perigo';

  @override
  String get thPointDate => 'Data';

  @override
  String get thPointDebris => 'Detritos';

  @override
  String get thPointDig => 'Escavação';

  @override
  String get thPointDimensions => 'Dimensões';

  @override
  String get thPointDiscPillar => 'Pilar de disco';

  @override
  String get thPointDiscPillars => 'Pilares de disco';

  @override
  String get thPointDiscStalactite => 'Estalactite de disco';

  @override
  String get thPointDiscStalactites => 'Estalactites de disco';

  @override
  String get thPointDiscStalagmite => 'Estalagmite de disco';

  @override
  String get thPointDiscStalagmites => 'Estalagmites de disco';

  @override
  String get thPointDisk => 'Disco';

  @override
  String get thPointElectricLight => 'Luz elétrica';

  @override
  String get thPointEntrance => 'Entrada';

  @override
  String get thPointExtra => 'Extra';

  @override
  String get thPointExVoto => 'Ex-voto';

  @override
  String get thPointFixedLadder => 'Escada fixa';

  @override
  String get thPointFlowstone => 'Travertino';

  @override
  String get thPointFlowstoneChoke => 'Bloqueio de travertino';

  @override
  String get thPointFlute => 'Flauta';

  @override
  String get thPointGate => 'Portão';

  @override
  String get thPointGradient => 'Gradiente';

  @override
  String get thPointGuano => 'Guano';

  @override
  String get thPointGypsum => 'Gesso';

  @override
  String get thPointGypsumFlower => 'Flor de gesso';

  @override
  String get thPointHandrail => 'Corrimão';

  @override
  String get thPointHeight => 'Altura';

  @override
  String get thPointHelictite => 'Helictite';

  @override
  String get thPointHelictites => 'Helictites';

  @override
  String get thPointHumanBones => 'Ossos humanos';

  @override
  String get thPointIce => 'Gelo';

  @override
  String get thPointIcePillar => 'Pilar de gelo';

  @override
  String get thPointIceStalactite => 'Estalactite de gelo';

  @override
  String get thPointIceStalagmite => 'Estalagmite de gelo';

  @override
  String get thPointKarren => 'Karren';

  @override
  String get thPointLabel => 'Rótulo';

  @override
  String get thPointLowEnd => 'Extremidade baixa';

  @override
  String get thPointMapConnection => 'Conexão de mapa';

  @override
  String get thPointMasonry => 'Alvenaria';

  @override
  String get thPointMoonmilk => 'Leite de lua';

  @override
  String get thPointMud => 'Lama';

  @override
  String get thPointMudcrack => 'Rachadura de lama';

  @override
  String get thPointNamePlate => 'Placa de nome';

  @override
  String get thPointNarrowEnd => 'Extremidade estreita';

  @override
  String get thPointNoEquipment => 'Sem equipamento';

  @override
  String get thPointNoWheelchair => 'Sem cadeira de rodas';

  @override
  String get thPointPaleoMaterial => 'Material paleontológico';

  @override
  String get thPointPassageHeight => 'Altura da passagem';

  @override
  String get thPointPebbles => 'Seixos';

  @override
  String get thPointPendant => 'Pendente';

  @override
  String get thPointPhoto => 'Foto';

  @override
  String get thPointPillar => 'Pilar';

  @override
  String get thPointPillarsWithCurtains => 'Pilares com cortinas';

  @override
  String get thPointPillarWithCurtains => 'Pilar com cortinas';

  @override
  String get thPointPopcorn => 'Popcorn';

  @override
  String get thPointRaft => 'Balsa';

  @override
  String get thPointRaftCone => 'Cone de balsa';

  @override
  String get thPointRemark => 'Observação';

  @override
  String get thPointRimstoneDam => 'Dique de travertino';

  @override
  String get thPointRimstonePool => 'Piscina de travertino';

  @override
  String get thPointRoot => 'Raiz';

  @override
  String get thPointRope => 'Corda';

  @override
  String get thPointRopeLadder => 'Escada de corda';

  @override
  String get thPointSand => 'Areia';

  @override
  String get thPointScallop => 'Escalope';

  @override
  String get thPointSection => 'Seção';

  @override
  String get thPointSeedGermination => 'Germinação de sementes';

  @override
  String get thPointSink => 'Pia';

  @override
  String get thPointSnow => 'Neve';

  @override
  String get thPointSodaStraw => 'Canudo de refrigerante';

  @override
  String get thPointSpring => 'Fonte';

  @override
  String get thPointStalactite => 'Estalactite';

  @override
  String get thPointStalactites => 'Estalactites';

  @override
  String get thPointStalactitesStalagmites => 'Estalactites e estalagmites';

  @override
  String get thPointStalactiteStalagmite => 'Estalactite e estalagmite';

  @override
  String get thPointStalagmite => 'Estalagmite';

  @override
  String get thPointStalagmites => 'Estalagmites';

  @override
  String get thPointStation => 'Estação';

  @override
  String get thPointStationName => 'Nome da estação';

  @override
  String get thPointSteps => 'Degraus';

  @override
  String get thPointTraverse => 'Travessia';

  @override
  String get thPointTreeTrunk => 'Tronco de árvore';

  @override
  String get thPointU => 'Usuário';

  @override
  String get thPointVegetableDebris => 'Detritos vegetais';

  @override
  String get thPointViaFerrata => 'Via Ferrata';

  @override
  String get thPointVolcano => 'Vulcão';

  @override
  String get thPointWalkway => 'Passarela';

  @override
  String get thPointWallCalcite => 'Calcita de parede';

  @override
  String get thPointWater => 'Água';

  @override
  String get thPointWaterDrip => 'Gotejamento de água';

  @override
  String get thPointWaterFlow => 'Fluxo de água';

  @override
  String get thPointWheelchair => 'Cadeira de rodas';

  @override
  String get thLineAbyssEntrance => 'Entrada do Abismo';

  @override
  String get thLineArrow => 'Seta';

  @override
  String get thLineBorder => 'Borda';

  @override
  String get thLineCeilingMeander => 'Meandro do Teto';

  @override
  String get thLineCeilingStep => 'Degrau do Teto';

  @override
  String get thLineChimney => 'Chaminé';

  @override
  String get thLineContour => 'Contorno';

  @override
  String get thLineDripline => 'Linha de Gotejamento';

  @override
  String get thLineFault => 'Falha';

  @override
  String get thLineFixedLadder => 'Escada Fixa';

  @override
  String get thLineFloorMeander => 'Meandro do Piso';

  @override
  String get thLineFloorStep => 'Degrau do Piso';

  @override
  String get thLineFlowstone => 'Travertino';

  @override
  String get thLineGradient => 'Gradiente';

  @override
  String get thLineHandrail => 'Corrimão';

  @override
  String get thLineJoint => 'Junta';

  @override
  String get thLineLabel => 'Rótulo';

  @override
  String get thLineLowCeiling => 'Teto Baixo';

  @override
  String get thLineMapConnection => 'Conexão de Mapa';

  @override
  String get thLineMoonmilk => 'Leite de Lua';

  @override
  String get thLineOverhang => 'Saliente';

  @override
  String get thLinePit => 'Poço';

  @override
  String get thLinePitch => 'Lance';

  @override
  String get thLinePitChimney => 'Chaminé do Poço';

  @override
  String get thLineRimstoneDam => 'Dique de Travertino';

  @override
  String get thLineRimstonePool => 'Piscina de Travertino';

  @override
  String get thLineRockBorder => 'Borda de Rocha';

  @override
  String get thLineRockEdge => 'Borda de Rocha';

  @override
  String get thLineRope => 'Corda';

  @override
  String get thLineRopeLadder => 'Escada de Corda';

  @override
  String get thLineSection => 'Seção';

  @override
  String get thLineSlope => 'Declive';

  @override
  String get thLineSteps => 'Degraus';

  @override
  String get thLineSurvey => 'Levantamento';

  @override
  String get thLineU => 'Usuário';

  @override
  String get thLineViaFerrata => 'Via Ferrata';

  @override
  String get thLineWalkWay => 'Passarela';

  @override
  String get thLineWall => 'Parede';

  @override
  String get thLineWaterFlow => 'Fluxo de Água';

  @override
  String get thCommandOptionAdjust => 'Ajustar';

  @override
  String get thCommandOptionAlign => 'Alinhar';

  @override
  String get thCommandOptionAltitude => 'Altitude';

  @override
  String get thCommandOptionAltitudeFix => 'Ref. 0 (fix)';

  @override
  String get thCommandOptionAltitudeValue => 'Altitude';

  @override
  String get thCommandOptionAnchors => 'Âncoras';

  @override
  String get thCommandOptionAuthor => 'Autor';

  @override
  String get thCommandOptionBorder => 'Borda';

  @override
  String get thCommandOptionClip => 'Recortar';

  @override
  String get thCommandOptionClose => 'Fechar';

  @override
  String get thCommandOptionContext => 'Contexto';

  @override
  String get thCommandOptionCopyright => 'Direitos Autorais';

  @override
  String get thCommandOptionCS => 'CS';

  @override
  String get thCommandOptionDateValue => 'Data';

  @override
  String get thCommandOptionDimensionsValue => 'Dimensões';

  @override
  String get thCommandOptionDist => 'Distância';

  @override
  String get thCommandOptionExplored => 'Explorado';

  @override
  String get thCommandOptionExtend => 'Estender';

  @override
  String get thCommandOptionFlip => 'Virar';

  @override
  String get thCommandOptionFrom => 'De';

  @override
  String get thCommandOptionHead => 'Cabeça';

  @override
  String get thCommandOptionId => 'ID';

  @override
  String get thCommandOptionLengthUnit => 'Unidade';

  @override
  String get thCommandOptionLineDirection => 'Direção';

  @override
  String get thCommandOptionLineGradient => 'Gradiente';

  @override
  String get thCommandOptionLineHeight => 'Altura';

  @override
  String get thCommandOptionLinePointDirection => 'Direção';

  @override
  String get thCommandOptionLinePointGradient => 'Gradiente';

  @override
  String get thCommandOptionLSize => 'Tamanho L';

  @override
  String get thCommandOptionMark => 'Marca';

  @override
  String get thCommandOptionName => 'Nome';

  @override
  String get thCommandOptionOutline => 'Contorno';

  @override
  String get thCommandOptionOrientation => 'Orientação';

  @override
  String get thCommandOptionPassageHeightValue => 'Altura da Passagem';

  @override
  String get thCommandOptionPlace => 'Lugar';

  @override
  String get thCommandOptionPointHeightValue => 'Altura do Ponto';

  @override
  String get thCommandOptionPLScale => 'Escala';

  @override
  String get thCommandOptionProjection => 'Projeção';

  @override
  String get thCommandOptionRebelays => 'Rebelays';

  @override
  String get thCommandOptionReverse => 'Reverter';

  @override
  String get thCommandOptionScrap => 'Sucata';

  @override
  String get thCommandOptionScrapScale => 'Escala';

  @override
  String get thCommandOptionSketch => 'Esboço';

  @override
  String get thCommandOptionSmooth => 'Suavizar';

  @override
  String get thCommandOptionStationNames => 'Nomes das estações';

  @override
  String get thCommandOptionStations => 'Estações';

  @override
  String get thCommandOptionSubtype => 'Subtipo';

  @override
  String get thCommandOptionText => 'Texto';

  @override
  String get thCommandOptionTitle => 'Título';

  @override
  String get thCommandOptionUnrecognizedCommandOption => 'Opção de Comando Não Reconhecida';

  @override
  String get thCommandOptionVisibility => 'Visibilidade';

  @override
  String get thCommandOptionWalls => 'Paredes';

  @override
  String get thMultipleChoiceAdjustHorizontal => 'Horizontal';

  @override
  String get thMultipleChoiceAdjustVertical => 'Vertical';

  @override
  String get thMultipleChoiceAlignBottom => 'Inferior';

  @override
  String get thMultipleChoiceAlignBottomLeft => 'Inferior Esquerdo';

  @override
  String get thMultipleChoiceAlignBottomRight => 'Inferior Direito';

  @override
  String get thMultipleChoiceAlignCenter => 'Centro';

  @override
  String get thMultipleChoiceAlignLeft => 'Esquerda';

  @override
  String get thMultipleChoiceAlignRight => 'Direita';

  @override
  String get thMultipleChoiceAlignTop => 'Superior';

  @override
  String get thMultipleChoiceAlignTopLeft => 'Superior Esquerdo';

  @override
  String get thMultipleChoiceAlignTopRight => 'Superior Direito';

  @override
  String get thMultipleChoiceOnOffOff => 'Desligado';

  @override
  String get thMultipleChoiceOnOffOn => 'Ligado';

  @override
  String get thMultipleChoiceOnOffAutoAuto => 'Automático';

  @override
  String get thMultipleChoiceFlipNone => 'Nenhum';

  @override
  String get thMultipleChoiceArrowPositionBegin => 'Início';

  @override
  String get thMultipleChoiceArrowPositionBoth => 'Ambos';

  @override
  String get thMultipleChoiceArrowPositionEnd => 'Fim';

  @override
  String get thMultipleChoiceLinePointGradientPoint => 'Ponto';

  @override
  String get thMultipleChoiceOutlineIn => 'Dentro';

  @override
  String get thMultipleChoiceOutlineOut => 'Fora';

  @override
  String get thMultipleChoicePlaceDefault => 'Padrão';
}
