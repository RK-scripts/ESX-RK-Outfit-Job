Config = {}

Config.JobGrades = {
    ['police'] = { minGrade = 2 }, --grado minimo per salvare ed eliminare gli outfit
    ['ambulance'] = { minGrade = 2 },
    -- Aggiungi altri lavori e gradi qui
}

Config.Locations = {
    ['police'] = vector3(452.6, -993.3, 30.6),
    ['ambulance'] = vector3(-27.6206, -1103.8569, 26.4223),
    -- Aggiungi altre coordinate qui
}

Config.Locale = {

    ['wardrobe'] = 'Guardaroba',
    ['wear_uniform'] = 'Indossa Divisa',
    ['wear_uniform_desc'] = 'Seleziona una divisa da indossare',
    ['remove_uniform'] = 'Rimuovi Divisa',
    ['remove_uniform_desc'] = 'Torna ai vestiti civili',
    ['save_outfit'] = 'Salva Outfit',
    ['save_outfit_desc'] = 'Salva la divisa attuale',
    ['delete_uniform'] = 'Elimina Divisa',
    ['delete_uniform_desc'] = 'Rimuovi una divisa salvata',
    ['available_uniforms'] = 'Divise Disponibili',
    ['delete_uniforms'] = 'Elimina Divise',
    ['open_wardrobe'] = 'Apri Guardaroba',
    

    ['save_outfit_title'] = 'Salva Outfit',
    ['outfit_name'] = 'Nome Outfit',
    ['outfit_name_desc'] = 'Inserisci un nome per questo outfit',
    ['min_grade'] = 'Grado Minimo',
    ['min_grade_desc'] = 'Grado minimo richiesto per utilizzare questo outfit',
    

    ['no_uniforms_available'] = 'Nessuna divisa disponibile per il tuo grado',
    ['uniform_worn'] = 'Divisa indossata',
    ['civilian_clothes_worn'] = 'Vestiti civili indossati',
    ['not_wearing_uniform'] = 'Non stai indossando una divisa',
    ['outfit_saved'] = 'Outfit salvato con successo',
    ['uniform_deleted'] = 'Divisa eliminata con successo',
    ['grade_required'] = 'Grado richiesto: %s',
    ['insufficient_grade'] = 'Non hai il grado richiesto per indossare questa divisa',
    

    ['confirm_delete'] = 'Conferma Eliminazione',
    ['confirm_delete_desc'] = 'Sei sicuro di voler eliminare la divisa "%s"?'
}
