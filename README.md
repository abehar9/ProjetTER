# Conception d’un outil de Optimization Chez LPC

## Présentation

Ce projet a été développé dans le cadre d’un TER (Travail d’Étude et de Recherche) de Master 1 MIASHS parcours Informatique et Cognition de l’Université Grenoble Alpes. Il propose la conception d’un outil de Optimization Chez LPC pour optimiser leur processus logistique. 
D’après nos échanges avec Mme. Laundry, cheffe de projet, chez DPC les employeurs doivent délivrer environ 600 commandes par jour, normalement réparties sur des agents traitant chacun environ 30 commandes par jour. Le processus logistique actuel est le suivant: réception des palettes hétérogènes (produits mélanges), stockage par tri et mise en stock en palettes homogènes dans l’entrepôt (système type IKEA), et finalement la préparation de commandes par picking d'articles variés pour créer des palettes hétérogènes selon les commandes clients. Selon DPC la productivité actuelle est jugée insuffisante et le côté ergonomie peut être amélioré pour éviter la quantité actuelle d'accidents du travail des employés. 

Notre projet vise à analyser la situation actuelle et essayer de donner des suggestions pour optimiser l’ergonomie des employés en ligne avec les commandes qui sont demandées.

Pour répondre à notre demande, nous avons utilisé un Solveur LPG en language PDDL, capable de trouver des solutions en fonction de contraintes fortes et/ou faibles. Les objectifs de l’outil ont été de répondre à un maximum de contraintes pour chaque solution et de permettre de tester des scénarios de contraintes. 

## Objectifs du projet

- Analyser le processus logistique actuel de LPC/DPC afin d’identifier ses limites et points d’amélioration.
- Modéliser les différentes étapes du processus (réception, stockage, préparation de commandes) à l’aide de PDDL.
- Utiliser le solveur LPG pour générer des plans optimisés en fonction de contraintes définies.
- Évaluer la productivité actuelle et proposer des pistes d’amélioration pour atteindre les objectifs de production (environ 600 commandes par jour).
- Étudier les possibilités d’optimisation ergonomique afin de réduire les risques d’accidents du travail.
- Tester différents scénarios de contraintes fortes et faibles pour comparer les solutions proposées.
- Analyser l’impact des modifications de processus sur l’efficacité globale et l’organisation du travail.


## Principe de fonctionnement du projet

Le projet génère plusieurs fichiers de domaine qui modélisent le processus logistique. Les informations sur ce processus ont été recueillies grâce aux observations de la doctorante Alexandra Sicco. Ces fichiers de domaine visent à reproduire le fonctionnement du processus ainsi que l’ensemble des agents, objets et actions possibles.

Les fichiers de problème décrivent différents environnements initiaux et définissent des objectifs précis à atteindre. Une fois traités par le solveur, ils produisent une séquence d’actions optimisée afin d’atteindre ces objectifs de la manière la plus efficace possible.

Dans notre dépôt Git, vous trouverez les fichiers de domaine. Chaque fichier est commenté afin de présenter clairement ses fonctionnalités, les actions définies ainsi que les types d’objets utilisés, ce qui permet de comprendre facilement le fonctionnement du système. Les fichiers de problème, souvent nommés p00x.pddl, sont également documentés de manière similaire afin d’être facilement lisibles et compréhensibles.

En analysant les étapes résultantes proposées par le solveur, nous sommes en mesure d’identifier les points faibles du processus, de mettre en évidence de nouvelles opportunités de réduction des coûts et d’évaluer l’impact des différentes solutions sur le plan ergonomique.

## Technologies utilisées
- Langage principal : **PDDL**
- Solveur : **LPG**
- Environnement : **local uniquement** (pas de base de données, ni de serveur distant)

**LPG**: Le solveur est un algorithme spécialisé dans la résolution de problèmes complexes sous contraintes. Il est capable d’optimiser les solutions en fonction des priorités définies. Le projet utilise LPG, un solveur open source, réputé pour sa robustesse et son efficacité dans la gestion de contraintes complexes.

**PDDL**: (Planning Domain Definition Language) est un langage standard utilisé en intelligence artificielle pour décrire des problèmes de planification automatisée. Il permet de définir un domaine, comprenant les actions possibles et leurs effets, ainsi qu’un problème spécifique avec un état initial et un objectif à atteindre. Grâce à cette représentation formelle, les planificateurs peuvent générer automatiquement une séquence d’actions permettant de résoudre le problème de manière efficace.

En PDDL, une tâche de planification est décrite à l’aide de deux fichiers : un fichier de domaine et un fichier de problème. Le fichier de domaine définit les règles générales de l’environnement, telles que les prédicats et les actions disponibles, tandis que le fichier de problème spécifie une situation particulière avec les objets, l’état initial et l’objectif à atteindre. Le planificateur utilise ces deux fichiers pour générer automatiquement un plan permettant d’atteindre l’objectif.

## Guide du Projet TO DO

TODO  
files included: with descriptions 

## Installation - Projet PDDL avec LPG-td

### 1. Prérequis
- **Système d'exploitation** : Windows, Linux (Debian recommandé pour la compatibilité native).
- **Terminal** : Accès à un terminal (bash, PowerShell, etc.).
- **Solveur** : Exécutable `lpg-td` (téléchargé et extrait dans le répertoire du projet).
- **Optionnel** : Docker (recommandé si vous rencontrez des problèmes de dépendances sur votre système hôte).


### 2. Installation
**Sans Docker:**
1. **Téléchargement** : Téléchargez l'archive correspondant à votre système :
   - LPG-td Linux
   - LPG-td Windows
2. **Extraction** :
   - Sous **Linux**, placez l'archive dans votre dossier et exécutez :
     ```bash
     gunzip lpgtd-linux.tar.gz
     tar xvf lpgtd-linux.tar
     ```
   - Sous **Windows**, utilisez un outil comme WinZip ou 7-Zip pour extraire les fichiers.
3. **Vérification** : Assurez-vous que le fichier `lpg-td` (ou `lpg-td.exe`) est présent dans le répertoire de travail.


**Avec Docker:**

**1. Installation de Docker Desktop**
1. Accédez à la page officielle : [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/).
2. Téléchargez **Docker Desktop for Mac (Apple Silicon)**.
3. Installez le fichier `.dmg` en déplaçant l'icône dans votre dossier **Applications**.
4. Ouvrez **Docker Desktop** et laissez l'application s'initialiser complètement.
5. Redémarrez votre ordinateur pour assurer la bonne configuration des outils système.



**2. Préparation du solveur dans le terminal**
1. Décompressez l'archive du solveur :

   `tar -xvf lpgtd-1_4-linux.tar.gz`
   
   Vous devez obtenir un dossier nommé `LPG-td-1.4`. Restez dans le répertoire parent de ce dossier.
2. Faites le command `docker --version` (juste pour voir si docker est bien installé correctement)
3. Exécutez 

    `docker run --platform linux/amd64 -it --mount type=bind,source=<ABSOLUTE_PATH_TO_LPG-td-1.4>,target=/LPG-td-1.4 debian:bookworm bash`

    Normalement, vous devez entrer dans un container Docker.
4. Ensuite si vous faites 
    `ls /LPG-td-1.4` 
    Vous devez voir tout le contenu de votre dossier. Vous vous placez dans le dossier avec 
    `cd /LPG-td-1.4`
    Puis vous pouvez faire un `./lpg-td`
5. Pour quitter le container Docker, tu exécutes la commande `exit`. Pour re-rentrer dedans, vous refaites la même commande ci-dessus.

### 3. Cloner le dépôt
Ouvrir un terminal et exécuter :

`git clone https://github.com/abehar9/ProjetTER.git`

`cd ProjetTER`

### 4. Utilisation
Pour exécuter le solveur, utilisez la syntaxe suivante dans votre terminal :

./lpg-td -o <domaine.pddl> -f <probleme.pddl> -n 1`

### 5. Pour commencer TO DO
Pour prendre en main le solveur, suivez ces étapes :

1. **Initialisation** : Commencez avec les fichiers `domainfileX.pddl` et `p00X.pddl` fournis dans le dossier.
2. **Observation** : Exécutez la commande de base (`-n 1`) pour observer le format de sortie et les solutions proposées par le solveur.
3. **Expérimentation** :
   - **Comparaison** : Testez différents fichiers de problèmes pour comparer les temps de résolution.
   - **Analyse** : Modifiez les fichiers de domaine pour ajouter de la complexité (Timed Initial Literals, Derived Predicates) et analysez l'impact sur les performances du moteur de recherche.
4. **Configuration avancée** : Consultez le fichier `README-LPGTD` original situé dans le dossier du projet pour ajuster les paramètres de recherche (`-noise`, `-seed`, `-cputime`, etc.) afin d'optimiser les résultats selon vos besoins spécifiques.


### 6. Aide et Dépannage
- **Permissions** : Sous Linux, si le fichier n'est pas reconnu comme exécutable, accordez les droits nécessaires avec :
  ```bash
  chmod +x lpg-td.

## Vidéo de démonstration TO DO 
TO DO

## Points à Améliorer TO DO
xxx


## Licence TO DO 
Ce projet a été réalisé à des fins pédagogiques dans le cadre d’un TER à l’Université Grenoble Alpes.
Il peut être utilisé, modifié ou adapté à des fins non commerciales. 

## Auteurs
Projet développé par six étudiants du Master MIASHS – Université Grenoble Alpes : 
- Andrea Behar 
- Anesie Martiniani 

Maître d’ouvrage : 
- Mme Landry Aurélie


## Documentation

TODO
La documentation complète, incluant le manuel d’installation, est disponible dans le dossier docs/.
