# Reference API

Documentation API generatee automatiquement via TypeDoc.

## Generation

```bash
cd /Users/malo/Projects/TaskFlow
npm run docs:all
```

## Resultat

- HTML: `docs/reference/api/index.html`
- Doxygen: `docs/reference/doxygen/html/index.html`
- Configuration: `lambda/typedoc.json`

## Bonnes pratiques

- Ajouter des commentaires JSDoc sur chaque handler et utilitaire partage.
- Regenerer la doc apres chaque changement de signature publique.

