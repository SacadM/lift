/**
 * @param {vscode} vscode the entry to vscode plugin api
 * @param {vscode.Uri} selectedFile currently selected file in vscode explorer
 * @param {vscode.Uri[]} selectedFiles currently multi-selected files in vscode explorer
 */
async function run(vscode, selectedFile, selectedFiles) {
    const lines = [];
    for (const file of selectedFiles) {
        lines.push('<file path="' + file.path + '">');
        lines.push(new TextDecoder().decode(await vscode.workspace.fs.readFile(file)));
        lines.push('</file>\n');
    }
    await vscode.env.clipboard.writeText(lines.join('\n'));
    vscode.window.showInformationMessage('Copied to clipboard');
}
await run(vscode, selectedFile, selectedFiles);