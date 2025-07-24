const express = require('express');
const app = express();
app.use(express.json());

const commands = new Map(); // Храним команды для игроков

app.post('/command', (req, res) => {
    const { userId, command } = req.body;
    commands.set(userId, command);
    res.sendStatus(200);
});

app.get('/command', (req, res) => {
    const userId = req.query.userId;
    res.json({ command: commands.get(userId) || "" });
});

app.listen(3000, () => console.log('Сервер запущен!'));
