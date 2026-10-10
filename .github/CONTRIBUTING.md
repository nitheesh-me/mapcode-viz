# Contributing to Mapcode Visualization

Thank you for considering contributing to Mapcode Visualization! We welcome contributions of all kinds, including bug fixes, new features, documentation improvements, and more.

## How to Contribute

### 1. Fork the Repository
1. Navigate to the [repository](https://github.com/nitheesh-me/mapcode-viz).
2. Click the "Fork" button to create your own copy of the repository.

### 2. Clone Your Fork
```bash
git clone https://github.com/nitheesh-me/mapcode-viz
cd mapcode-viz
```

### 3. Create a New Branch
```bash
git checkout -b feature/your-feature-name
```

### 4. Make Changes
- Add your changes to the appropriate files.
- Ensure your code follows the project's style and conventions.
- Test your changes locally.

### 5. Commit Your Changes
```bash
git add .
git commit -m "Add your commit message here"
```

### 6. Push Your Changes
```bash
git push origin feature/your-feature-name
```

### 7. Open a Pull Request
1. Go to the original repository.
2. Click the "Pull Requests" tab.
3. Click "New Pull Request" and select your branch.
4. Provide a clear description of your changes.

### 8. Adding an Algorithm
1. Create `algorithms/<chapter>/<kebab-case-name>.typ` by copying `algorithms/basics/fibonacci.typ`, the reference template, and add an `#include` line under the right chapter in `main.typ`.
2. Each file has these parts:
   - `== Title` and a problem statement with examples
   - `*As mapcode:*`: one math block defining $I$, $X$, $A$, $\rho$, $F$, $\pi$, with an explicit $\bot$ case
   - optionally a `#pseudo[...]` box
   - a figure built with `mapcode-viz(rho, F, pi, X_h: ...)(inst)`, followed by `#legend`
3. Render states with the shared helpers in `lib/viz.typ` instead of hand-rolled rects and grids:
   - `vec-view`, `table-view`, `array-view` for tables and arrays
   - `tree-view`, `graph-view` for trees and graphs
   - `board-view`, `pegs-view` for boards and pegs
   - `lq` (lilaq) for plots
   Colours come from the tokens in `lib/style.typ`.
4. Rules every mapcode must follow:
   - **Compute inside F.** Never compute the answer outside F and have F copy it.
   - **Keep F strict.** Cells start as $\bot$ (`none`), and a cell becomes defined only once every cell it depends on is defined.
   - **Instance data belongs to I.** Strings, arrays, coins and edges reach F and $\pi$ through closures. They are not stored in X and not read from file-level globals inside `X_h`.
   - **Code matches math.** The math block must describe exactly what the code does.
5. Typst pitfalls:
   - In math, write `pi` or `mpi`, never `\pi`.
   - Write `x_(i+1)`, not `x_{i+1}`.
   - Use a single `\` for line breaks in math.
6. Run `typst compile main.typ` and check that it builds without warnings, that the answer node is correct, and that the figure fits the page. `mapcode-viz` auto-shrinks to the page width, so tune `group-size` and `spacing` for legibility.

## Guidelines
- **Code Style**: Follow the existing code style and structure.
- **Commit Messages**: Use clear and concise commit messages.
- **Documentation**: Update documentation for any new features or changes.
- **Testing**: Ensure your changes are tested and do not break existing functionality.

## Reporting Issues
If you encounter any issues, please [open an issue](https://github.com/nitheesh-me/mapcode-viz/issues) with the following details:
- A clear description of the problem.
- Steps to reproduce the issue.
- Any relevant logs or screenshots.

## Code of Conduct
Please be respectful and constructive in all interactions.

---

Thank you for your contributions!