const Skill = require('../models/Skill');

exports.getSkills = async (req, res) => {
  try {
    const skills = await Skill.find();
    res.json(skills);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createSkill = async (req, res) => {
  try {
    const s = new Skill(req.body);
    await s.save();
    res.status(201).json(s);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteSkill = async (req, res) => {
  try {
    await Skill.findByIdAndDelete(req.params.id);
    res.json({ message: 'Deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createSkillsBulk = async (req, res) => {
  try {
    const { names } = req.body;
    if (!Array.isArray(names)) return res.status(400).json({ error: 'Names must be an array' });
    const skills = names.map(name => ({ name, level: 'Expert' }));
    const result = await Skill.insertMany(skills);
    res.status(201).json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteSkillsBulk = async (req, res) => {
  try {
    const { ids } = req.body;
    if (!Array.isArray(ids)) return res.status(400).json({ error: 'IDs must be an array' });
    await Skill.deleteMany({ _id: { $in: ids } });
    res.json({ message: 'Skills deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
exports.updateSkill = async (req, res) => {
  try {
    const s = await Skill.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(s);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};
