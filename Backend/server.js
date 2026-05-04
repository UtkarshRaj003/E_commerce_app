const dotenv = require('dotenv');

dotenv.config();

process.on('uncaughtException', (error) => {
  console.error(`Uncaught Exception: ${error.message}`);
  process.exit(1);
});

const connectDB = require('./config/db');
const app = require('./app');

connectDB();

const PORT = process.env.PORT || 10000;
const environment = process.env.NODE_ENV || 'development';

const server = app.listen(PORT,'0.0.0.0', () => {
  console.log(`Server running in ${environment} mode on port ${PORT}`);
});

process.on('unhandledRejection', (reason) => {
  console.error('Unhandled Rejection:', reason);
  server.close(() => process.exit(1));
});
