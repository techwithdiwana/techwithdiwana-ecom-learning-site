const express = require('express');
const fs = require('fs').promises;
const path = require('path');
const app = express();
app.use(express.json());
const DB = path.join(__dirname,'db.json');
async function readDB(){try{return JSON.parse(await fs.readFile(DB,'utf8'))}catch(e){return{courses:[]}}}
async function writeDB(data){await fs.writeFile(DB,JSON.stringify(data,null,2))}
app.get('/api/courses',async(req,res)=>{const db=await readDB();res.json(db.courses||[])});
app.post('/api/purchase',async(req,res)=>{const {courseId,user}=req.body||{};if(!courseId)return res.status(400).json({error:'courseId required'});
const db=await readDB();db.purchases=db.purchases||[];db.purchases.push({id:Date.now(),courseId,user,ts:new Date().toISOString()});
await writeDB(db);res.json({success:true,message:'Purchase recorded (demo)'})});
const PORT=process.env.PORT||3000;app.listen(PORT,()=>console.log(`Backend running on ${PORT}`));