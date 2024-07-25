local L = LibStub("AceLocale-3.0"):NewLocale("PepeGoldTracker", "frFR")

if L then
    --[[
        Commands
    ]]
    L["Usage: |cffd4af37/pepe|r or |cffd4af37/pepegoldtracker|r followed by one the commands below"] = "Syntaxe: |cffd4af37/pepe|r or |cffd4af37/pepegoldtracker|r suivi d'une des commandes ci-dessous"
    L["- open character window"] = "- ouvre la fenêtre de suivi des personnages"
    L["- open guild window"] = "- ouvre la fenêtre de suivi des guildes"
    L["- print the version number of the addon."] = "- affiche la version de l'addon"
    L["- open a window showing what realm you are logged on."] = "- ouvre un panneau affichant le serveur ou vous êtes actuellement connecté"
    L["- open a window showing what gold you have."] = "- ouvre un panneau affichant la quantité d'or actuelle"
    L["- toggle visibility of minimap button"] = "- permet d'activer ou désactivé le boutton de la minimap"
    L["The current PepeGoldTracker version is: %s"] = "La version actuelle de PepeGoldTracker est: %s"
    L["- open the options window."] = "- ouvre la fenêtre des options"

    --[[
        General
    ]]
    L[" initializated successfully"] = " initialisé avec succès"
    L["Character registered successfully."] = "Personnage enregistré avec succès."
    L["Guild registered successfully."] = "Guilde enregistré avec succès."
    L["An error occured while updating the guild."] = "Une erreur est survenu lors de la mise à jour de la guilde"
    L["Search"] = "Rechercher"
    L["Export"] = "Export"
    L["Only show this realm"] = "Affiche seulement ce serveur"
    L["Realm"] = "Serveur"
    L["Faction"] = "Faction"
    L["Gold"] = "Or"
    L["Last update"] = "Dernière mise à jour"
    L["No results found."] = "Aucun résultat trouvé."
    L["Current results: %s"] = "Résultats actuel: %s"
    L["Yes"] = "Oui"
    L["No"] = "Non"
    L["Are you sure you want to delete %s"] = "Êtes-vous sûr de vouloir supprimer %s"
    L["Close"] = "Fermer"
    L["Search.. name, realm, faction, date"] = "Recherche.. nom, serveur, faction, date"
    L["Guild name"] = "Nom de guilde"

    --[[
        Options
    ]]
    L["Addon that help tracking gold stored accross your account"] = "Un addon utilitaire vous permettant de suivre facilement l'or présent sur votre compte"
    L["Author: "] = "Auteur: "
    L["Version: "] = "Version: "
    L["Show minimap icon"] = "Affiche l'icon de minimap"
    L["Whether or not to show the minimap icon."] = "Si vous souhaitez affiché l'icone de minimap"
    L["Show current realm window"] = "Affiche la fenêtre du serveur actuel"
    L["Show current gold window"] = "Affiche la quantité d'or actuelle"
    L["Auto-open the current realm window for character that are level 10 and under"] = "Ouvre automatiquement la fenêtre du serveur actuel pour les personnages de niveau 10 ou moins"
    L["Auto-open the current gold window."] = "Ouvre automatiquement la fenêtre affichant la quantité d'or actuelle"
    L["Multi-account synching"] = "Synchronization multi-comptes"
    L["Synchronization Options"] = "Options de synchronization"
    L["Note: this feature is still experimental and will only sync characters and not guild."] = "Note: cette fonctionnalité est encore en expérimentation, elle ne fonctionne uniquement pour la synchronization des personnages, pas des guildes."
    L["Open sync window"] = "Ouvrir la fenêtre de synchronization"
    L["Guilds Options"] = "Options des guildes"
    L["Characters Options"] = "Options des personnages"
    L["Gold Widget Options"] = "Options pour le widget d'or"
    L["Guilds overview options"] = "Options de suivi des guildes"
    L["Select wich columns you want to hide"] = "Sélectionnez quelles colonnes vous souhaitez cacher"
    L["Characters overview options"] = "Options de suivi des personnages"
    L["Gold Widget overview options"] = "Options du widget d'or"
    L["Synchronization icon"] = "Îcone de synchronisation"
    L["General overview table configuration"] = "Configuration générale des tables"
    L["This section allow to customize the tables from overviews panels"] = "Cette section vous permet de personnaliser les tables des panneaux de suivis."
    L["Gold format display"] = "Format d'affichage de l'or"
    L["Lock gold window position"] = "Vérouiller la position de la fenêtre d'or actuel"
    L["Data display source"] = "Source des données"

    -- Data Display
    L["Character"] = "Personnage"
    L["Current realm"] = "Serveur actuel"
    L["Account"] = "Compte"

    -- Gold format
    L["Blizzard"] = "Blizzard"
    L["Blizzard short (Only show gold)"] = "Blizzard court (Seulement l'or)"
    L["Spaced (2 222g 22s 22c)"] = "Espacé (2 222g 22s 22c)"
    L["Spaced short (2 222g)"] = "Espacé court (2 222g)"
    L["Coma (2,222g 22s 22c)"] = "Virgule (2,222g 22s 22c)"
    L["Coma short (2,222g)"] = "Virgule court (2,222g)"

    --[[
        Minimap
    ]]
    L["Toggle character window"] = "Ouvre la fenêtre de suivi des personnages"
    L["Toggle guild window"] = "Ouvre la fenêtre de suivi des guildes"
    L["Toggle realm window"] = "Ouvre la fenêtre du serveur connecté"-- Revoir la traduction

    --[[
        Current Realm Window
    ]]
    L["Current Realm:"] = "Serveur actuel"
    L["Connected realm:"] = "Serveurs connectés"

    --[[
        Guild Viewer Window
    ]]
    L["Guilds overview"] = "Suivi des guildes"
    L["Purge DB"] = "Purger BD"
    L["Clear the guild database.\nThis effect is permanent and cannot be undone."] = "Efface la base de donnée des guildes.\nL'effet est permanent et ne peut être annulé"
    L["Only show guilds that are on this realm."] = "Affiche seulement les guildes qui sont sur ce serveur."
    L["Delete guild"] = "Supression de guilde"
    L["All guilds have been successfully deleted."] = "Toutes les guildes ont étés supprimées avec succès"
    L["Are you sure you want to delete ALL guilds?"] = "Êtes-vous sûr de vouloir supprimer TOUTES les guildes?"
    L["Guild %s deleted successfully"] = "Guilde %s supprimée avec succès"
    L["Detecting a bugged guild ID: %s. The guild will be deleted make sure to confirm information while exporting!"] = "Détection d'une guilde bug ID: %s. La guilde sera supprimée. Veuillez vérifié vos informations lors de l'export!"

    --[[
        Export guild winodw
    ]]
    L["Export guilds data"] = "Exporter les données des guildes"

    --[[
        Export character window
    ]]
    L["Export characters data"] = "Exporter les données des personnages"

    --[[
        Character Viewer Window
    ]]
    L["Character overview"] = "Suivi des personnages"
    L["Only show characters that are on this realm."] = "Affiche seulement les personnes qui sont sur ce serveur"
    L["Character name"] = "Nom du personnage"
    L["Character %s deleted successfully"] = "Personnage %s supprimé avec succès"
    L["Delete character"] = "Suppression de personnage"
    L["Synched character"] = "Personnage synchronisé"

    --[[
        Synchronization
    ]]
    L["You cannot synchronize with yourself."] = "Vous ne pouvez pas faire de synchronisation avec vous-même."
    L["%s is requesting to sync your data."] = "%s souhaite synchroniser vos données."
    L["Synchronization completed. You may now log off."] = "Synchronisation terminée. Vous pouvez désormais vous déconnecter."
    L["Character data sent for: %s"] = "Données de personnage envoyé pour: %s"
    L["Started synching. Do not close your game."] = "Synchronisation commencée. Ne fermez pas votre jeu."
    L["Sync request has been sent to %s, awaiting their confirmation."] = "Demande de synchronisation envoyé à %s"
    L["Synching: %s"] = "Synchronisation: %s"
    L["Synchronization completed"] = "Synchronisation terminée"
    L["%s declined your sync request."] = "%s a refusé votre demande de synchronisation."
    L["%s accepted your sync request."] = "%s a accepté votre demande de synchronisation"
    L['Send request'] = "Envoyer la demande"
    L["Enter the character you wish to sync with \n*Must be on the same realm/connected-realm"] = "Entrez le nom du personnage à synchroniser.\n*Vous devez être sur le même serveur."
    L["Synchronization request"] = "Demande de synchronisation"
    L["Pending request"] = "Requête en attente"
    L['Synchronization'] = "Synchronisation"
end