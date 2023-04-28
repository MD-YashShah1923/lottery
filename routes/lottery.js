const express = require('express');
const router = express.Router();
const create = require('../controller/Lotterycontroller');


router.post('/', create.createLotter);
router.post('/',create.importLuckyNumber);
router.post('/',create.getLotteryLuckyNumbers);

module.exports = router;