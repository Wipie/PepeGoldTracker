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
    L["- toggle visibility of minimap button"] = "- permet d'activer ou désactivé le boutton de la minimap"
    L["The current PepeGoldTracker version is: "] = "La version actuelle de PepeGoldTracker est: "

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
    L["Current results: "] = "Résultats actuel: "
    L["Yes"] = "Oui"
    L["No"] = "Non"
    L["Are you sure you want to delete "] = "Êtes-vous sûr de vouloir supprimer "
    L["Close"] = "Fermer"
    L["Search.. name, realm, faction, date"] = "Recherche.. nom, serveur, faction, date"
    L["Guild name"] = "Nom de guilde"
    L[" deleted successfully"] = " supprimé avec succès"

    --[[
        Options
    ]]
    L["Addon that help tracking gold stored accross your account"] = "Un addon utilitaire vous permettant de suivre facilement l'or présent sur votre compte"
    L["Author: "] = "Auteur: "
    L["Version: "] = "Version: "
    L["Show minimap icon"] = "Affiche l'icon de minimap"
    L["Whether or not to show the minimap icon."] = "Si vous souhaitez affiché l'icone de minimap"
    L["Show current realm window"] = "Affiche la fenêtre du serveur actuel"
    L["Auto-open the current realm window for character that are level 10 and under"] = "Ouvre automatiquement la fenêtre du serveur actuel pour les personnages de niveau 10 ou moins"

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
    L["Guild tracking"] = "Suivi des guildes"
    L["Purge DB"] = "Purger BD"
    L["Clear the guild database.\nThis effect is permanent and cannot be undone."] = "Efface la base de donnée des guildes.\nL'effet est permanent et ne peut être annulé"
    L["Only show guilds that are on this realm."] = "Affiche seulement les guildes qui sont sur ce serveur."
    L["Delete guild"] = "Supression de guilde"
    L["All guilds have been successfully deleted."] = "Toutes les guildes ont étés supprimées avec succès"
    L["Are you sure you want to delete ALL guilds?"] = "Êtes-vous sûr de vouloir supprimer TOUTES les guildes?"
    L["Guild "] = "Guilde "
    L["Detecting a bugged guild ID: "] = "Détection d'une guilde bug ID: "
    L[". The guild will be deleted make sure to confirm information while exporting!"] = ". La guilde sera supprimée. Veuillez vérifié vos informations lors de l'export!"

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
    L["Character tracking"] = "Suivi des personnages"
    L["Only show characters that are on this realm."] = "Affiche seulement les personnes qui sont sur ce serveur"
    L["Character name"] = "Nom du personnage"
    L["Character "] = "Personnage "
    L["Delete character"] = "Suppression de personnage"
end