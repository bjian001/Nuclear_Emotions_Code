local util = nil    ---@class Util

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
---@class SeekModeScript : ScriptComponent
---@field _duration number
---@field progress number [UI(Range={0, 1}, Slider)]
---@field autoplay boolean

local ae_attribute_main = {
	["ADBE_Opacity_1_1"]={
		{{0.33333333, 0, 0.66666667, 1, }, {0, 3, }, {{0, }, {100, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 0, }, {3, 54, }, {{100, }, {100, }, }, {6417, }, {0, }, }, 
		{{0.85, 0, 0.999, 1, }, {54, 59, }, {{100, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.85, 0, 0.999, 1, }, {59, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Opacity_2_2"]={
		{{0.33333333, 0, 0.66666667, 1, }, {0, 3, }, {{0, }, {100, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 0, }, {3, 54, }, {{100, }, {100, }, }, {6417, }, {0, }, }, 
		{{0.85, 0, 0.999, 1, }, {54, 59, }, {{100, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.85, 0, 0.999, 1, }, {59, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Opacity_3_3"]={
		{{0.33333333, 0, 0.66666667, 1, }, {0, 3, }, {{0, }, {100, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 0, }, {3, 48, }, {{100, }, {100, }, }, {6417, }, {0, }, }, 
		{{0.42, 0, 0.999, 1, }, {48, 59, }, {{100, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.42, 0, 0.999, 1, }, {59, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Opacity_4_4"]={
		{{0.33333333, 0, 0.66666667, 1, }, {0, 3, }, {{0, }, {100, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 0, }, {3, 40, }, {{100, }, {100, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 1, }, {40, 59, }, {{100, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 1, }, {59, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Opacity_5_5"]={
		{{0.33333333, 0, 0.66666667, 1, }, {3, 11, }, {{100, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0, 0.833333333, 0, }, {11, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
	},  
    -- ["solidFill_opacity_1_2"]={
	-- 	{{0.166666667, 0.166666667, 0.833333333, 0.833333333, }, {7, 21, }, {{0, }, {100, }, }, {6417, }, {1, }, }, 
	-- }, 
    -- ["solidFill_opacity_2_4"]={
	-- 	{{0.166666667, 0.166666667, 0.833333333, 0.833333333, }, {12, 33, }, {{0, }, {12, }, }, {6417, }, {1, }, },  
	-- }, 
    -- ["solidFill_opacity_3_6"]={
	-- 	{{0.166666667, 0.166666667, 0.833333333, 0.833333333, }, {10, 28, }, {{0, }, {100, }, }, {6417, }, {1, }, },  
	-- }, 
    ["ADBE_Opacity_1_0"]={
		{{0.33333333, 0, 0.66666667, 1, }, {0, 30, }, {{0, }, {100, }, }, {6417, }, {0, }, }, 
	}, 
}

local ae_attribute_dis = {
	["ADBE_Opacity_0_0"]={
		-- {{0.33333333, 0, 0.721836398, 1, }, {1, 55, }, {{88, }, {50, }, }, {6417, }, {0, }, }, 
		-- {{0.067618291, 0, 0.765912934, 0, }, {55, 60, }, {{50, }, {50, }, }, {6417, }, {0, }, }, 
		{{0.278159959, 0, 0.66666667, 1, }, {5, 59, }, {{50, }, {88, }, }, {6417, }, {0, }, }, 
		{{0.278159959, 0, 0.66666667, 1, }, {59, 60, }, {{88, }, {88, }, }, {6417, }, {0, }, }, 
	}, 
}

local ae_attribute_dark = {
	["ADBE_Displacement_Map_0003_0_0"]={
		-- {{0.325309057, 0.410066786, 0.605284606, 0.80514977, }, {0, 38, }, {{-1200, }, {-66, }, }, {6417, }, {0, }, }, 
		-- {{0.25467655, 0.928544468, 0.429036424, 1, }, {38, 58, }, {{-66, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.27, 0, 0.610011682, 0, }, {58, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.469513312, 0, 0.770472199, 0.552508337, }, {2, 22, }, {{0, }, {240.153846, }, }, {6417, }, {0, }, }, 
		{{0.243889981, 0.182209664, 0.666052536, 0.92242408, }, {22, 60, }, {{240.153846, }, {1500, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Displacement_Map_0005_0_1"]={
		-- {{0.256066599, 0.881861255, 0.597548286, 0.915904897, }, {0, 39, }, {{750, }, {58.694009, }, }, {6417, }, {0, }, }, 
		-- {{0.325066552, 0.353645377, 0.434999229, 1, }, {39, 58, }, {{58.694009, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.27, 0, 0.625600766, 0, }, {58, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.45815681, 0, 0.714335381, 1, }, {2, 21, }, {{0, }, {-185.161823, }, }, {6417, }, {0, }, }, 
		{{0.176054199, 0.000450534, 0.641909689, 0.826339584, }, {21, 60, }, {{-185.161823, }, {-1000, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_92959d1fb849aa97f8ff858_0001_0_2"]={
		-- {{0.600703643, 0, 0.826210959, 1, }, {0, 58, }, {{50, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.826210959, 0, }, {58, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.146322727, 0, 0.355326257, 1, }, {2, 60, }, {{0, }, {50, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_92959d1fb849aa97f8ff858_0004_0_3"]={
		-- {{0.22, 0, 0.79, 1, }, {0, 58, }, {{50, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.79, 0, }, {58, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.166069979, 0, 0.540809726, 1, }, {2, 60, }, {{0, }, {50, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_f27e10b94d011bf31c57ec1_0002_1_4"]={
		-- {{0.33333333, 0, 0.66666667, 1, }, {39, 58, }, {{33, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.66666667, 0, }, {58, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 1, }, {2, 21, }, {{0, }, {33, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 1, }, {21, 60, }, {{33, }, {33, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Scale_1_5"]={
		-- {{0.12,0.12,0.12, 0.473666667,0.473666667,0.12, 0.64,0.64,0.64, 1,1,0.64, }, {0, 58, }, {{50, 50, 100, }, {100, 100, 100, }, }, {6414, }, {0, }, }, 
		-- {{0.166666667,0.166666667,0.166666667, 0.166666667,0.166666667,0.166666667, 0.66666667,0.66666667,0.66666667, 0.66666667,0.66666667,0.66666667, }, {58, 60, }, {{100, 100, 100, }, {100, 100, 100, }, }, {6414, }, {0, }, }, 
		{{0.270625429,0.270625429,0.33333333, 0,0,0.33333333, 0.543358011,0.543358011,0.66666667, 1,1,0.66666667, }, {2, 7, }, {{100, 100, 100, }, {102, 102, 100, }, }, {6414, }, {0, }, }, 
		{{0.591979176,0.591979176,0.33333333, 0,0,0.33333333, 0.992857143,0.992857143,0.66666667, 1,1,0.66666667, }, {7, 52, }, {{102, 102, 100, }, {50, 50, 100, }, }, {6414, }, {0, }, }, 
		{{0.591979176,0.591979176,0.33333333, 0,0,0.33333333, 0.992857143,0.992857143,0.66666667, 1,1,0.66666667, }, {52, 60, }, {{50, 50, 100, }, {50, 50, 100, }, }, {6414, }, {0, }, }, 
	}, 
}

local ae_attribute_middle = {
	["ADBE_Displacement_Map_0003_0_0"]={
		-- {{0.27, 0.84, 0.578009586, 1, }, {0, 58, }, {{-1500, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.27, 0, 0.6, 0, }, {58, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.260853039, 0, 0.667938, 0.24248869, }, {2, 60, }, {{0, }, {1500, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Displacement_Map_0005_0_1"]={
		-- {{0.27, 0.842449222, 0.578009586, 1, }, {0, 58, }, {{1500, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.27, 0, 0.6, 0, }, {58, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.260853039, 0, 0.651338887, 0.146680627, }, {2, 60, }, {{0, }, {-1500, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_92959d1fb849aa97f8ff858_0001_0_2"]={
		-- {{0.243858816, 0, 0.707143886, 1, }, {0, 58, }, {{40, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.707143886, 0, }, {58, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.233782156, 0, 0.646250033, 1, }, {2, 60, }, {{0, }, {40, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_92959d1fb849aa97f8ff858_0004_0_3"]={
		-- {{0.22, 0, 0.670931139, 1, }, {0, 58, }, {{180, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.670931139, 0, }, {58, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.222574681, 0, 0.57671618, 1, }, {2, 60, }, {{0, }, {180, }, }, {6417, }, {0, }, }, 
	}, 
	["PEDG_0002_0_4"]={
		-- {{0.33333333, 0, 0.66666667, 1, }, {0, 55, }, {{0.4, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.66666667, 0, }, {55, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.202014978, 0, 0.500197269, 1, }, {5, 60, }, {{0, }, {0.4, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Luma_Key_0002_1_5"]={
		-- {{0.001, 0, 0.5, 1, }, {0, 10, }, {{170, }, {85, }, }, {6417, }, {0, }, }, 
		-- {{0.001, 0, 0.833333333, 0, }, {10, 60, }, {{85, }, {85, }, }, {6417, }, {0, }, }, 
		{{1, 0, 0.999, 1, }, {44, 60, }, {{85, }, {170, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Luma_Key_0002_1_6"]={
		-- {{0.001, 0, 0.5, 1, }, {0, 10, }, {{85, }, {170, }, }, {6417, }, {0, }, }, 
		-- {{0.001, 0, 0.833333333, 0, }, {10, 60, }, {{170, }, {170, }, }, {6417, }, {0, }, }, 
		{{1, 0, 0.999, 1, }, {44, 60, }, {{170, }, {85, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Scale_1_7"]={
		-- {{0.12,0.12,0.12, 0.473666667,0.473666667,0.12, 0.567727699,0.567727699,0.64, 1,1,0.64, }, {0, 58, }, {{50, 50, 100, }, {100, 100, 100, }, }, {6414, }, {0, }, }, 
		-- {{0.166666667,0.166666667,0.166666667, 0.166666667,0.166666667,0.166666667, 0.66666667,0.66666667,0.66666667, 0.66666667,0.66666667,0.66666667, }, {58, 60, }, {{100, 100, 100, }, {100, 100, 100, }, }, {6414, }, {0, }, }, 
		{{0.315114574,0.315114574,0.33333333, 0,0,0.33333333, 0.495391531,0.495391531,0.66666667, 1,1,0.66666667, }, {0, 5, }, {{100, 100, 100, }, {104, 104, 100, }, }, {6414, }, {0, }, }, 
		{{0.6521444,0.6521444,0.33333333, 0,0,0.33333333, 0.993617021,0.993617021,0.66666667, 1,1,0.66666667, }, {5, 54, }, {{104, 104, 100, }, {50, 50, 100, }, }, {6414, }, {0, }, }, 
		{{0.6521444,0.6521444,0.33333333, 0,0,0.33333333, 0.993617021,0.993617021,0.66666667, 1,1,0.66666667, }, {54, 60, }, {{50, 50, 100, }, {50, 50, 100, }, }, {6414, }, {0, }, }, 
	}, 
}

local ae_attribute_light = {
	["ADBE_Displacement_Map_0003_0_0"]={
		-- {{0.256733053, 0.702772373, 0.594614603, 0.916841683, }, {0, 39, }, {{-2000, }, {-121.480463, }, }, {6417, }, {0, }, }, 
		-- {{0.278250871, 0.391442163, 0.697647278, 1, }, {39, 60, }, {{-121.480463, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.27, 0, 0.682016215, 0, }, {60, 80, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.242689494, 0, 0.721749129, 0.808525783, }, {0, 21, }, {{0, }, {249.658887, }, }, {6417, }, {0, }, }, 
		{{0.228281108, 0.058115264, 0.702481231, 0.330176495, }, {21, 60, }, {{249.658887, }, {2000, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Displacement_Map_0005_0_1"]={
		-- {{0.284224251, 0.467328639, 0.617554835, 0.887790793, }, {0, 38, }, {{2700, }, {121.51367, }, }, {6417, }, {0, }, }, 
		-- {{0.283082052, 0.945072446, 0.637199537, 1, }, {38, 60, }, {{121.51367, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.27, 0, 0.621867705, 0, }, {60, 80, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.305872283, 0, 0.716917948, 0.481015929, }, {0, 22, }, {{0, }, {-221.216498, }, }, {6417, }, {0, }, }, 
		{{0.245428893, 0.074917825, 0.735399354, 0.57209999, }, {22, 60, }, {{-221.216498, }, {-2700, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_92959d1fb849aa97f8ff858_0001_0_2"]={
		-- {{0.33333333, 0, 0.810184879, 1, }, {0, 60, }, {{30, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.33333333, 0, 0.810184879, 0, }, {60, 80, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.107949691, 0, 0.50893168, 1, }, {0, 60, }, {{0, }, {30, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_92959d1fb849aa97f8ff858_0004_0_3"]={
		-- {{0.22, 0, 0.79, 1, }, {0, 60, }, {{270, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.22, 0, 0.79, 0, }, {60, 80, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.131953321, 0, 0.606093197, 1, }, {0, 60, }, {{0, }, {270, }, }, {6417, }, {0, }, }, 
	}, 
	["PEDG_0002_0_4"]={
		-- {{0.612112747, 0, 0.667184038, 1, }, {10, 58, }, {{1.2, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.766513614, 0, }, {58, 60, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.31844476, 0, 0.394401817, 1, }, {2, 50, }, {{0, }, {1.2, }, }, {6417, }, {0, }, }, 
		{{0.31844476, 0, 0.394401817, 1, }, {50, 60, }, {{1.2, }, {1.2, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Luma_Key_0002_1_5"]={
		-- {{0.22, 0, 0.78, 1, }, {0, 12, }, {{233, }, {140, }, }, {6417, }, {0, }, }, 
		-- {{0.22, 0, 0.833333333, 0, }, {12, 49, }, {{140, }, {140, }, }, {6417, }, {0, }, }, 
		-- {{0.696010496, 0, 0.897161491, 1, }, {49, 60, }, {{140, }, {233, }, }, {6417, }, {0, }, }, 
		-- {{0.22, 0, 0.78, 0, }, {60, 80, }, {{233, }, {233, }, }, {6417, }, {0, }, }, 
		{{0.07179461, 0, 0.245773839, 1, }, {0, 13, }, {{233, }, {140, }, }, {6417, }, {0, }, }, 
		{{0.22, 0, 0.833333333, 0, }, {13, 40, }, {{140, }, {140, }, }, {6417, }, {0, }, }, 
		{{0.22, 0, 0.78, 1, }, {40, 60, }, {{140, }, {233, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Scale_1_6"]={
		-- {{0.12,0.12,0.12, 0.49,0.49,0.12, 0.64,0.64,0.64, 1,1,0.64, }, {0, 60, }, {{50, 50, 100, }, {100, 100, 100, }, }, {6414, }, {0, }, }, 
		-- {{0.12,0.12,0.12, 0.12,0.12,0.12, 0.66666667,0.66666667,0.66666667, 0.66666667,0.66666667,0.66666667, }, {60, 80, }, {{100, 100, 100, }, {100, 100, 100, }, }, {6414, }, {0, }, }, 
		{{0.290784197,0.290784197,0.33333333, 0,0,0.33333333, 0.460508509,0.460508509,0.66666667, 1,1,0.66666667, }, {0, 4, }, {{100, 100, 100, }, {107, 107, 100, }, }, {6414, }, {0, }, }, 
		{{0.615018658,0.615018658,0.33333333, 0,0,0.33333333, 0.993877551,0.993877551,0.66666667, 1,1,0.66666667, }, {4, 55, }, {{107, 107, 100, }, {50, 50, 100, }, }, {6414, }, {0, }, }, 
		{{0.615018658,0.615018658,0.33333333, 0,0,0.33333333, 0.993877551,0.993877551,0.66666667, 1,1,0.66666667, }, {55, 60, }, {{50, 50, 100, }, {50, 50, 100, }, }, {6414, }, {0, }, }, 
	}, 
}

local ae_attribute_highlight = {
	["ADBE_Displacement_Map_0003_0_0"]={
		-- {{0.1, 0.62, 0.41, 1, }, {0, 60, }, {{-1500, }, {-300, }, }, {6417, }, {0, }, }, 
		-- {{0.27, 0, 0.41, 0, }, {60, 80, }, {{-300, }, {-300, }, }, {6417, }, {0, }, }, 
		{{0.428801861, 0, 0.691951656, 1, }, {0, 60, }, {{-300, }, {1500, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Displacement_Map_0005_0_1"]={
		-- {{0.1, 0.621807759, 0.41, 1, }, {0, 60, }, {{100, }, {-450, }, }, {6417, }, {0, }, }, 
		-- {{0.27, 0, 0.41, 0, }, {60, 80, }, {{-450, }, {-450, }, }, {6417, }, {0, }, }, 
		{{0.235491242, 0, 0.771920347, 0.372895311, }, {0, 60, }, {{-450, }, {-1000, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_92959d1fb849aa97f8ff858_0001_0_2"]={
		-- {{0.166666667, 0.166666667, 0.833333333, 0.833333333, }, {0, 60, }, {{33, }, {10, }, }, {6417, }, {1, }, }, 
		-- {{0.166666667, 0.166666667, 0.833333333, 0.833333333, }, {60, 80, }, {{10, }, {10, }, }, {6417, }, {1, }, }, 
		{{0.166666667, 0.166666667, 0.833333333, 0.833333333, }, {0, 60, }, {{10, }, {33, }, }, {6417, }, {1, }, }, 
	}, 
	["ADBE_IE_92959d1fb849aa97f8ff858_0004_0_3"]={
		-- {{0.166666667, 0.166666667, 0.833333333, 0.833333333, }, {0, 60, }, {{270, }, {0, }, }, {6417, }, {1, }, }, 
		-- {{0.166666667, 0.166666667, 0.833333333, 0.833333333, }, {60, 80, }, {{0, }, {0, }, }, {6417, }, {1, }, }, 
		{{0.166666667, 0.166666667, 0.833333333, 0.833333333, }, {0, 60, }, {{0, }, {270, }, }, {6417, }, {1, }, }, 
	}, 
	["PEDG_0002_0_4"]={
		-- {{0.778935255, 0, 0.819836788, 1, }, {0, 60, }, {{1.2, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.766513614, 0, }, {60, 82, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.089712234, 0, 0.265809564, 1, }, {2, 50, }, {{0, }, {1.2, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Luma_Key_0002_1_5"]={
		-- {{0.27, 0, 0.31, 1, }, {0, 42, }, {{255, }, {210, }, }, {6417, }, {0, }, }, 
		-- {{0.318557671, 0, 0.752645879, 1, }, {42, 60, }, {{210, }, {255, }, }, {6417, }, {0, }, }, 
		-- {{0.22, 0, 0.752645879, 0, }, {60, 80, }, {{255, }, {255, }, }, {6417, }, {0, }, }, 
		{{0.001, 0, 0.58, 1, }, {0, 5, }, {{255, }, {205, }, }, {6417, }, {0, }, }, 
		{{0.69, 0, 0.73, 1, }, {5, 60, }, {{205, }, {255, }, }, {6417, }, {0, }, }, 
	}, 
}

local AETools = AETools or {}
AETools.__index = AETools

local function deepcopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        -- setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function AETools.new(attrs)
    local self = setmetatable({}, AETools)
    self.attrs = attrs

    local max_frame = 0
    local min_frame = 100000
    for _,v in pairs(attrs) do
        for i = 1, #v do
            local content = v[i]
            local cur_frame_min = content[2][1]
            local cur_frame_max = content[2][2]
            max_frame = math.max(cur_frame_max, max_frame)
            min_frame = math.min(cur_frame_min, min_frame)

            if content[4] ~= nil and content[5] ~= nil and (content[4][1] == 6413 or content[4][1] == 6415) and content[5][1] == 0 then
                local p0 = content[3][1]
                local totalLen = 0
                local lenInfo = {}
                lenInfo[0] = 0
                for test=1,200,1 do
                    local coord = self._cubicBezier3D(content[3][1], content[3][3], content[3][4], content[3][2], test/200)
                    local length = math.sqrt((coord[1]-p0[1])*(coord[1]-p0[1])+(coord[2]-p0[2])*(coord[2]-p0[2]))
                    p0 = coord
                    totalLen = totalLen + length
                    lenInfo[test] = totalLen
                    -- print(test/200 .. " coord: "..coord[1].." - "..coord[2])
                end
                for test=1,200,1 do
                    lenInfo[test] = lenInfo[test]/(lenInfo[200]+0.000001)
                    -- print(test/200 .. "  "..lenInfo[test])
                end
                content['lenInfo'] = lenInfo
            end
        end
    end

    self.all_frame = max_frame - min_frame
    self.min_frame = min_frame

    return self
end

function AETools:CurFrame(_p)
    local frame = math.floor(_p*self.all_frame)
    return frame + self.min_frame
end

function AETools:AllFrame(_p)
    return self.all_frame
end

function AETools._remap01(a,b,x)
    if x < a then return 0 end
    if x > b then return 1 end
    return (x-a)/(b-a)
end

function AETools._cubicBezier(p1, p2, p3, p4, t)
    return {
        p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
        p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
    }
end

function AETools._cubicBezier3D(p1, p2, p3, p4, t)
    if #p1 >= 3 then
        return {
            p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
            p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
            p1[3]*(1.-t)*(1.-t)*(1.-t) + 3*p2[3]*(1.-t)*(1.-t)*t + 3*p3[3]*(1.-t)*t*t + p4[3]*t*t*t,
        }
    else
        return {
            p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
            p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
            0,
        }
    end
end

function AETools:_cubicBezierSpatial(lenInfo, p1, p2, p3, p4, t)
    local p = 0
    if t <= 0 then
        p = 0
    elseif t >= 1 then
        p = 1
    else
        local ts = 0
        local te = 200
        for i=1,200,1 do
            if lenInfo[i] >= t then
                te = i
                ts = i-1
                break
            end
        end
        p = ts/200. + 0.005*(t-lenInfo[ts])/(lenInfo[te]-lenInfo[ts]+0.000001)
    end
    return self._cubicBezier3D(p1, p2, p3, p4, p)
end

function AETools:_cubicBezier01(_bezier_val, p, y_len)
    local x = self:_getBezier01X(_bezier_val, p, y_len)
    return self._cubicBezier(
        {0,0},
        {_bezier_val[1], _bezier_val[2]},
        {_bezier_val[3], _bezier_val[4]},
        {1, y_len},
        x
    )[2]
end

function AETools:_getBezier01X(_bezier_val, x, y_len)
    local ts = 0
    local te = 1
    -- divide and conque
    local times = 1
    repeat
        local tm = (ts+te)*0.5
        local value = self._cubicBezier(
            {0,0},
            {_bezier_val[1], _bezier_val[2]},
            {_bezier_val[3], _bezier_val[4]},
            {1, y_len},
            tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
        times = times +1
    until(te-ts < 0.001 and times < 50)

    return (te+ts)*0.5
end

function AETools._mix(a, b, x, type)
    if type == 1 then
        return a * (1-x) + b * x
    else
        return a + x
    end
end

function AETools:GetVal(_name, _progress)
    local content = self.attrs[_name]
    if content == nil then
        return nil
    end

    local cur_frame = _progress * self.all_frame + self.min_frame

    for i = 1, #content do
        local info = content[i]
        local start_frame = info[2][1]
        local end_frame = info[2][2]
        if cur_frame >= start_frame and cur_frame < end_frame then
            local cur_progress = self._remap01(start_frame, end_frame, cur_frame)
            local bezier = info[1]
            local value_range = info[3]
            local y_len = 1
            if (value_range[2][1] == value_range[1][1] and info[5] and info[5][1]==0 and #(value_range[1])==1) then
                y_len = 0
            end

            if #bezier > 4 then
                -- currently scale attrs contains more than 4 bezier values
                local res = {}
                for k = 1, 3 do
                    local cur_bezier = {bezier[k], bezier[k+3], bezier[k+3*2], bezier[k+3*3]}
                    local p = self:_cubicBezier01(cur_bezier, cur_progress, y_len)
                    res[k] = self._mix(value_range[1][k], value_range[2][k], p, y_len)
                end
                return res

            else
                local p = self:_cubicBezier01(bezier, cur_progress, y_len)
                if info[4] ~= nil and info[5] ~= nil and (info[4][1] == 6413 or info[4][1] == 6415) and info[5] and info[5][1] == 0 then
                    local coord = self:_cubicBezierSpatial(info['lenInfo'],
                                                            value_range[1], 
                                                            value_range[3], 
                                                            value_range[4], 
                                                            value_range[2], 
                                                            p)
                    return coord
                end

                if type(value_range[1]) == "table" then
                    local res = {}
                    for j = 1, #value_range[1] do
                        res[j] = self._mix(value_range[1][j], value_range[2][j], p, y_len)
                    end
                    return res
                end
                return self._mix(value_range[1], value_range[2], p, y_len)
            end
        end
    end

    local first_info = content[1]
    local start_frame = first_info[2][1]
    if cur_frame<start_frame then
        return deepcopy(first_info[3][1])
    end

    local last_info = content[#content]
    local end_frame = last_info[2][2]
    if cur_frame>=end_frame then
        return deepcopy(last_info[3][2])
    end

    return nil
end

local function remap(smin, smax, dmin, dmax, value)
	return (value - smin) / (smax - smin) * (dmax - dmin) + dmin
end

local function anchor(pivot, anchor, halfWidth, halfHeight, translate, rotate, scale)
	local anchor = Amaz.Vector4f(
		remap(-.5, .5, 1, -1, pivot[1]) * halfWidth + remap(-.5, .5, -(1 - scale.x), 1 - scale.x, anchor[1]) * halfWidth,
		remap(-.5, .5, 1, -1, pivot[2]) * halfHeight + remap(-.5, .5, -(1 - scale.y), 1 - scale.y, anchor[2]) * halfHeight,
		0,
		1
	)
	local mat = Amaz.Matrix4x4f()
	mat:setTRS(
		Amaz.Vector3f(
			remap(-.5, .5, -1, 1, pivot[1]) * halfWidth,
			remap(-.5, .5, -1, 1, pivot[2]) * halfHeight,
			0
		),
		Amaz.Quaternionf.eulerToQuaternion(Amaz.Vector3f(rotate.x / 180 * math.pi, rotate.y / 180 * math.pi, rotate.z / 180 * math.pi)),
		Amaz.Vector3f(1, 1, 1)
	)
	anchor = mat:multiplyVector4(anchor)
	return Amaz.Vector3f(anchor.x, anchor.y, anchor.z) + translate, rotate, scale
end

local util = {}     ---@class Util
local json = cjson.new()
local rootDir = nil
local record_t = {}

local function getBezierValue(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-t)*t+3*xc2*(1-t)*t*t+t*t*t
    ret[2] = 3*yc1*(1-t)*(1-t)*t+3*yc2*(1-t)*t*t+t*t*t
    return ret
end

local function getBezierDerivative(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-3*t)+3*xc2*(2-3*t)*t+3*t*t
    ret[2] = 3*yc1*(1-t)*(1-3*t)+3*yc2*(2-3*t)*t+3*t*t
    return ret
end

local function getBezierTfromX(controls, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts+te)/2
        local value = getBezierValue(controls, tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
    until(te-ts < 0.0001)

    return (te+ts)/2
end

local function changeVec2ToTable(val)
    return {val.x, val.y}
end

local function changeVec3ToTable(val)
    return {val.x, val.y, val.z}
end

local function changeVec4ToTable(val)
    return {val.x, val.y, val.z, val.w}
end

local function changeCol3ToTable(val)
    return {val.r, val.g, val.b}
end

local function changeCol4ToTable(val)
    return {val.r, val.g, val.b, val.a}
end

local function changeTable2Vec4(t)
    return Amaz.Vector4f(t[1], t[2], t[3], t[4])
end

local function changeTable2Vec3(t)
    return Amaz.Vector3f(t[1], t[2], t[3])
end

local function changeTable2Vec2(t)
    return Amaz.Vector2f(t[1], t[2])
end

local function changeTable2Col3(t)
    return Amaz.Color(t[1], t[2], t[3])
end

local function changeTable2Col4(t)
    return Amaz.Color(t[1], t[2], t[3], t[4])
end

local _typeSwitch = {
    ["vec4"] = function(v)
        return changeVec4ToTable(v)
    end,
    ["vec3"] = function(v)
        return changeVec3ToTable(v)
    end,
    ["vec2"] = function(v)
        return changeVec2ToTable(v)
    end,
    ["float"] = function(v)
        return tonumber(v)
    end,
    ["string"] = function(v)
        return tostring(v)
    end,
    ["col3"] = function(v)
        return changeCol3ToTable(v)
    end,
    ["col4"] = function(v)
        return changeCol4ToTable(v)
    end,

    -- change table to userdata
    ["_vec4"] = function(v)
        return changeTable2Vec4(v)
    end,
    ["_vec3"] = function(v)
        return changeTable2Vec3(v)
    end,
    ["_vec2"] = function(v)
        return changeTable2Vec2(v)
    end,
    ["_float"] = function(v)
        return tonumber(v)
    end,
    ["_string"] = function(v)
        return tostring(v)
    end,
    ["_col3"] = function(v)
        return changeTable2Col3(v)
    end,
    ["_col4"] = function(v)
        return changeTable2Col4(v)
    end,
}

local function typeSwitch()
    return _typeSwitch
end

local function createTableContent()
    -- Amaz.LOGI("lrc", "createTableContent")
    local t = {}
    for k,v in pairs(record_t) do
        t[k] = {}
        t[k]["type"] = v["type"]
        t[k]["val"] = v["func"](v["val"])
    end
    return t
end

function util.registerParams(_name, _data, _type)
    record_t[_name] = {
        ["type"] = _type,
        ["val"] = _data,
        ["func"] = _typeSwitch[_type]
    }
end

function util.getRegistedParams()
    return record_t
end

function util.setRegistedVal(_name, _data)
    record_t[_name]["val"] = _data
end

function util.getRootDir()
    if rootDir == nil then
        local str = debug.getinfo(2, "S").source
        rootDir = str:match("@?(.*/)")
    end
    Amaz.LOGI("lrc getRootDir 123", tostring(rootDir))
    return rootDir
end

function util.registerRootDir(path)
    rootDir = path
end

function util.bezier(controls)
    local control = controls
    if type(control) ~= "table" then
        control = changeVec4ToTable(controls)
    end
    return function (t, b, c, d)
        t = t/d
        local tvalue = getBezierTfromX(control, t)
        local value =  getBezierValue(control, tvalue)
        return b + c * value[2]
    end
end

function util.remap01(a,b,x)
    if x < a then return 0 end
    if x > b then return 1 end
    return (x-a)/(b-a)
end

function util.mix(a, b, x)
    return a * (1-x) + b * x
end

function util.CreateJsonFile(file_path)
    local t = createTableContent()
    local content = json.encode(t)
    local file = io.open(util.getRootDir()..file_path, "w+b")
    if file then
      file:write(tostring(content))
      io.close(file)
    end
end

function util.ReadFromJson(file_path)
    local file = io.input(util.getRootDir()..file_path)
    local json_data = json.decode(io.read("*a"))
    local res = {}
    for k, v in pairs(json_data) do
        local func = _typeSwitch["_"..tostring(v["type"])]
        res[k] = func(v["val"])
    end
    return res
end

function util.bezierWithParams(input_val_4, min_val, max_val, in_val, reverse)
    if type(input_val_4) == "tabke" then
        if reverse == nil then
            return util.bezier(input_val_4)(util.remap01(min_val, max_val, in_val), 0, 1, 1)
        else
            return util.bezier(input_val_4)(1-util.remap01(min_val, max_val, in_val), 0, 1, 1)
        end
    else
        if reverse == nil then
            return util.bezier(util.changeVec4ToTable(input_val_4))(util.remap01(min_val, max_val, in_val), 0, 1, 1)
        else
            return util.bezier(util.changeVec4ToTable(input_val_4))(1-util.remap01(min_val, max_val, in_val), 0, 1, 1)
        end
    end
end

function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)

    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end

    self.progress = 0
    self.curTime = 0
    self.startTime = 0
    self._duration = 3
    self.autoplay = true

    self.playDuration = 2

    self.ins = 0

	self.cur_frame = 0

    self.wave_speed = 2

    return self
end

function SeekModeScript:constructor()
end

function SeekModeScript:_adapt_onStart(comp)
    self.curTime = 0
    self.duration = 2.0
    self.values = {}
    self.params = {}
    self.anims = {}
    self.animDirty = true
    self.entity = comp.entity
    self.scaleCorrect = 1.0
    self.videoMat = self.entity.scene:findEntityBy("video"):getComponent("MeshRenderer").material
    self.modelMat = self.entity.scene:findEntityBy("quad"):getComponent("MeshRenderer").material
    self.fxaaMat = self.entity.scene:findEntityBy("fxaa"):getComponent("MeshRenderer").material
    self.blendMat = self.entity.scene:findEntityBy("blend"):getComponent("MeshRenderer").material
    self.transform = self.entity.scene:findEntityBy("quad"):getComponent("Transform")
    self.userPosition = Amaz.Vector3f(0, 0, 0)
    self.userEulerAngle = Amaz.Vector3f(0, 0, 0)
    self.userScale = Amaz.Vector3f(1, 1, 1)
end

function SeekModeScript:onStart(comp)
    self:_adapt_onStart(comp)
    self.attrsMain = AETools.new(ae_attribute_main)
    self.attrsDis = AETools.new(ae_attribute_dis)
    self.attrsDark = AETools.new(ae_attribute_dark)
    self.attrsMiddle = AETools.new(ae_attribute_middle)
    self.attrsLight = AETools.new(ae_attribute_light)
    self.attrsHighlight = AETools.new(ae_attribute_highlight)

    self.propGrain = comp.entity.scene:findEntityBy("lumi_grain"):getComponent("ScriptComponent").properties
    self.propBlurDark = comp.entity.scene:findEntityBy("Gaussian_Blur_Root_Dark"):getComponent("ScriptComponent").properties
    self.propTurbulenceDark = comp.entity.scene:findEntityBy("TurbulenceDisplacementDark"):getComponent("ScriptComponent").properties
    self.propTurbulenceMiddle = comp.entity.scene:findEntityBy("TurbulenceDisplacementMiddle"):getComponent("ScriptComponent").properties
    self.propTurbulenceLight = comp.entity.scene:findEntityBy("TurbulenceDisplacementLight"):getComponent("ScriptComponent").properties
    self.propTurbulenceHighlight = comp.entity.scene:findEntityBy("TurbulenceDisplacementHighlight"):getComponent("ScriptComponent").properties
    self.propKeyMiddle1 = comp.entity.scene:findEntityBy("LumaKey_Root_Middle1"):getComponent("ScriptComponent").properties
    self.propKeyMiddle2 = comp.entity.scene:findEntityBy("LumaKey_Root_Middle2"):getComponent("ScriptComponent").properties
    self.propKeyLight = comp.entity.scene:findEntityBy("LumaKey_Root_Light"):getComponent("ScriptComponent").properties
    self.propKeyHighlight = comp.entity.scene:findEntityBy("LumaKey_Root_Highlight"):getComponent("ScriptComponent").properties
    self.propDeepGlowMiddle = comp.entity.scene:findEntityBy("Deep_Glow_Root_Middle"):getComponent("ScriptComponent").properties
    self.propDeepGlowLight = comp.entity.scene:findEntityBy("Deep_Glow_Root_Light"):getComponent("ScriptComponent").properties
    self.propDeepGlowHighlight = comp.entity.scene:findEntityBy("Deep_Glow_Root_Highlight"):getComponent("ScriptComponent").properties
    self.matGrain = comp.entity.scene:findEntityBy("NoisePass"):getComponent("MeshRenderer").material
    self.matDarkDisplace = comp.entity.scene:findEntityBy("PassDarkDisplace"):getComponent("MeshRenderer").material
    self.matBlendDark = comp.entity.scene:findEntityBy("PassBlendDark"):getComponent("MeshRenderer").material
    self.matBlendMiddle = comp.entity.scene:findEntityBy("PassBlendMiddle"):getComponent("MeshRenderer").material
    self.matBlendLight = comp.entity.scene:findEntityBy("PassBlendLight"):getComponent("MeshRenderer").material
    self.matBlendHighlight = comp.entity.scene:findEntityBy("PassBlendHighlight"):getComponent("MeshRenderer").material
    self.matMiddleDisplace = comp.entity.scene:findEntityBy("PassMiddleDisplace"):getComponent("MeshRenderer").material
    self.matLightDisplace = comp.entity.scene:findEntityBy("PassLightDisplace"):getComponent("MeshRenderer").material
    self.matHighlightDisplace = comp.entity.scene:findEntityBy("PassHighlightDisplace"):getComponent("MeshRenderer").material
    self.animKira = comp.entity.scene:findEntityBy("PassKira"):getComponent("AnimSeqComponent")
    self.matTurbulenceDark = comp.entity.scene:findEntityBy("TurbulenceDisplacementDark"):searchEntity("Displacement"):getComponent("MeshRenderer").material
    self.matTurbulenceMiddle = comp.entity.scene:findEntityBy("TurbulenceDisplacementMiddle"):searchEntity("Displacement"):getComponent("MeshRenderer").material
    self.matTurbulenceLight = comp.entity.scene:findEntityBy("TurbulenceDisplacementLight"):searchEntity("Displacement"):getComponent("MeshRenderer").material
    self.matTurbulenceHighlight = comp.entity.scene:findEntityBy("TurbulenceDisplacementHighlight"):searchEntity("Displacement"):getComponent("MeshRenderer").material
    self.matKira = comp.entity.scene:findEntityBy("PassKira"):getComponent("MeshRenderer").material

    self.videoDarkDis = comp.entity.scene:findEntityBy("TurbulenceDisplacementDark"):searchEntity("Displacement"):getComponent("VideoAnimSeq")
    self.videoMiddleDis = comp.entity.scene:findEntityBy("TurbulenceDisplacementMiddle"):searchEntity("Displacement"):getComponent("VideoAnimSeq")
    self.videoLightDis = comp.entity.scene:findEntityBy("TurbulenceDisplacementLight"):searchEntity("Displacement"):getComponent("VideoAnimSeq")
    self.videoHighlightDis = comp.entity.scene:findEntityBy("TurbulenceDisplacementHighlight"):searchEntity("Displacement"):getComponent("VideoAnimSeq")
    if Amaz.Macros and Amaz.Macros.EditorSDK then
    else
        self.videoDarkDis.enableFixedSeekMode = true
        self.videoMiddleDis.enableFixedSeekMode = true
        self.videoLightDis.enableFixedSeekMode = true
        self.videoHighlightDis.enableFixedSeekMode = true
    end
end

function SeekModeScript:autoPlay(time)
    if Amaz.Macros and Amaz.Macros.EditorSDK then
        if self.autoplay then
            self.progress = time % self._duration / self._duration
        end
    else
        -- self.duration = self.endTime - self.startTime
        -- self.progress = time % self.duration / self.duration
        self.progress = math.mod(time/(self.duration+0.0001), 1)
    end
end

if Amaz.Macros and Amaz.Macros.EditorSDK then
    function SeekModeScript:onUpdate(comp, detalTime)
        self.blendMat:enableMacro("AMAZING_EDITOR_DEV", 1)
        self.modelMat:enableMacro("AMAZING_EDITOR_DEV", 1)

        self.lastTime = self.curTime
        self.curTime = self.curTime + detalTime
        self:autoPlay(self.curTime)
        self:seek(self.curTime - self.startTime)
    end
end

function SeekModeScript:_adapt_seek(time)
    local inputW = Amaz.BuiltinObject:getInputTextureWidth()
    local inputH = Amaz.BuiltinObject:getInputTextureHeight()
    local inputRatio = inputW / inputH
    local outputW = Amaz.BuiltinObject:getOutputTextureWidth()
    local outputH = Amaz.BuiltinObject:getOutputTextureHeight()
    local outputRatio = outputW / outputH
    local fitScale = Amaz.Vector3f(1, 1, 1)
    local extraScale = 1
    if inputRatio < outputRatio then
        fitScale.x = inputRatio
        extraScale = inputH / outputH
    else
        fitScale.x = outputRatio
        fitScale.y = outputRatio / inputRatio
        extraScale = inputW / outputW
    end

    local uvScale = Amaz.Vector2f(1, 1)
    local xRatio = inputRatio / outputRatio
    local yRatio = outputRatio / inputRatio
    if outputRatio > 1. then
        if outputRatio > inputRatio then
            uvScale.x = xRatio
        else
            uvScale.y = yRatio
        end
    elseif math.abs(outputRatio - 1.) < .1 then
        if inputRatio < 1. then
            uvScale.x = xRatio
        else
            uvScale.y = yRatio
        end
    elseif outputRatio < 1. then
        if math.abs(inputRatio - 1.) < .1 or outputRatio < inputRatio then
            uvScale.y = yRatio
        else
            uvScale.x = xRatio
        end
    end

    self.modelMat:setFloat("u_OutputWidth", outputW)
    self.modelMat:setFloat("u_OutputHeight", outputH)

    local userMat = Amaz.Matrix4x4f()
    userMat:setTRS(
        Amaz.Vector3f(self.userPosition.x * outputRatio, self.userPosition.y, self.userPosition.z),
        Amaz.Quaternionf.EulerToQuaternion(-self.userEulerAngle / 180 * math.pi),
        Amaz.Vector3f(1, 1, 1) * self.userScale.x * extraScale
    )
    userMat:invert_Full()

    local fitMat = Amaz.Matrix4x4f()
    fitMat:setTRS(Amaz.Vector3f(0, 0, 0), Amaz.Quaternionf.identity(), Amaz.Vector3f(uvScale.x, uvScale.y, 1))
    fitMat:invert_Full()

    self.modelMat:setMat4("userMat", userMat)
    self.modelMat:setMat4("fitMat", fitMat)
end

function SeekModeScript:seek(time)
    self:_adapt_seek(time)
    self:autoPlay(time)

    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    self.matTurbulenceDark:setFloat("width", w)
    self.matTurbulenceDark:setFloat("height", h)
    self.matTurbulenceMiddle:setFloat("width", w)
    self.matTurbulenceMiddle:setFloat("height", h)
    self.matTurbulenceLight:setFloat("width", w)
    self.matTurbulenceLight:setFloat("height", h)
    self.matTurbulenceHighlight:setFloat("width", w)
    self.matTurbulenceHighlight:setFloat("height", h)
    self.matKira:setFloat("width", w)
    self.matKira:setFloat("height", h)

    self.propGrain:set("curTime", self.progress)

    local opacityGrain = self.attrsDis:GetVal("ADBE_Opacity_0_0", self.progress)[1] / 100.
    self.matGrain:setFloat("opacity", opacityGrain)

    local blurDark = self.attrsDark:GetVal("ADBE_IE_f27e10b94d011bf31c57ec1_0002_1_4", self.progress)[1]
    self.propBlurDark:set("intensity", blurDark / 1.2)

    local disXDark = self.attrsDark:GetVal("ADBE_Displacement_Map_0003_0_0", self.progress)[1] / 1080. * 1.2
    local disYDark = -self.attrsDark:GetVal("ADBE_Displacement_Map_0005_0_1", self.progress)[1] / 1080. * 1.2
    self.matDarkDisplace:setVec2("offset", Amaz.Vector2f(disXDark, disYDark))
    local scaleXDark = self.attrsDark:GetVal("ADBE_Scale_1_5", self.progress)[1] / 100.
    local scaleYDark = self.attrsDark:GetVal("ADBE_Scale_1_5", self.progress)[2] / 100.
    self.matDarkDisplace:setVec2("scale", Amaz.Vector2f(scaleXDark, scaleYDark))

    local turbulenceIntensityDark = self.attrsDark:GetVal("ADBE_IE_92959d1fb849aa97f8ff858_0001_0_2", self.progress)[1] / 100.
    local turbulenceEvolutionDark = self.attrsDark:GetVal("ADBE_IE_92959d1fb849aa97f8ff858_0004_0_3", self.progress)[1]
    -- Amaz.LOGI("ldrldr", turbulenceIntensityDark)
    self.propTurbulenceDark:set("size", turbulenceIntensityDark)
    self.propTurbulenceDark:set("evolution", turbulenceEvolutionDark)

    local opacityBase = self.attrsMain:GetVal("ADBE_Opacity_5_5", self.progress)[1] / 100.
    local opacityDark = self.attrsMain:GetVal("ADBE_Opacity_4_4", self.progress)[1] / 100.
    self.matBlendDark:setFloat("baseOpacity", opacityBase)
    self.matBlendDark:setFloat("blendOpacity", opacityDark)

    local disXMiddle = self.attrsMiddle:GetVal("ADBE_Displacement_Map_0003_0_0", self.progress)[1] / 1080. * 1.2
    local disYMiddle = -self.attrsMiddle:GetVal("ADBE_Displacement_Map_0005_0_1", self.progress)[1] / 1080. * 1.2
    self.matMiddleDisplace:setVec2("offset", Amaz.Vector2f(disXMiddle, disYMiddle))
    local scaleXMiddle = self.attrsMiddle:GetVal("ADBE_Scale_1_7", self.progress)[1] / 100.
    local scaleYMiddle = self.attrsMiddle:GetVal("ADBE_Scale_1_7", self.progress)[2] / 100.
    self.matMiddleDisplace:setVec2("scale", Amaz.Vector2f(scaleXMiddle, scaleYMiddle))

    local thresMiddle1 = self.attrsMiddle:GetVal("ADBE_Luma_Key_0002_1_5", self.progress)[1]
    local thresMiddle2 = self.attrsMiddle:GetVal("ADBE_Luma_Key_0002_1_6", self.progress)[1]
    self.propKeyMiddle1:set("threshold", thresMiddle1)
    self.propKeyMiddle2:set("threshold", thresMiddle2)

    local turbulenceIntensityMiddle = self.attrsMiddle:GetVal("ADBE_IE_92959d1fb849aa97f8ff858_0001_0_2", self.progress)[1] / 100.
    local turbulenceEvolutionMiddle = self.attrsMiddle:GetVal("ADBE_IE_92959d1fb849aa97f8ff858_0004_0_3", self.progress)[1]
    self.propTurbulenceMiddle:set("size", turbulenceIntensityMiddle)
    self.propTurbulenceMiddle:set("evolution", turbulenceEvolutionMiddle)

    self.videoDarkDis:seekToTime(math.max(0, self.progress * 2.))
    self.videoMiddleDis:seekToTime(math.max(0, self.progress * 2.))
    -- Amaz.LOGI("ldrldr", tostring(self.videoDarkDis))

    local deepGlowMiddle = self.attrsMiddle:GetVal("PEDG_0002_0_4", self.progress)[1]
    self.propDeepGlowMiddle:set("glow_intensity", deepGlowMiddle * .2 * 1.25)

    local thresLight = self.attrsLight:GetVal("ADBE_Luma_Key_0002_1_5", self.progress)[1]
    self.propKeyLight:set("threshold", thresLight)

    local disXLight = self.attrsLight:GetVal("ADBE_Displacement_Map_0003_0_0", self.progress)[1] / 1080. * 1.2
    local disYLight = -self.attrsLight:GetVal("ADBE_Displacement_Map_0005_0_1", self.progress)[1] / 1080. * 1.2
    -- Amaz.LOGI("ldrldr", disXLight * 1080)
    self.matLightDisplace:setVec2("offset", Amaz.Vector2f(disXLight, disYLight))
    local scaleXLight = self.attrsLight:GetVal("ADBE_Scale_1_6", self.progress)[1] / 100.
    local scaleYLight = self.attrsLight:GetVal("ADBE_Scale_1_6", self.progress)[2] / 100.
    self.matLightDisplace:setVec2("scale", Amaz.Vector2f(scaleXLight, scaleYLight))

    local turbulenceIntensityLight = self.attrsLight:GetVal("ADBE_IE_92959d1fb849aa97f8ff858_0001_0_2", self.progress)[1] / 100.
    self.propTurbulenceLight:set("size", turbulenceIntensityLight)
    self.videoLightDis:seekToTime(math.max(0, self.progress * 2.))

    local deepGlowLight = self.attrsLight:GetVal("PEDG_0002_0_4", self.progress)[1]
    self.propDeepGlowLight:set("glow_intensity", deepGlowLight * .2 * 1.25)

    local opacityMiddle = self.attrsMain:GetVal("ADBE_Opacity_3_3", self.progress)[1] / 100.
    self.matBlendMiddle:setFloat("blendOpacity", opacityMiddle * 1)


    local opacityLight = self.attrsMain:GetVal("ADBE_Opacity_2_2", self.progress)[1] / 100.
    self.matBlendLight:setFloat("blendOpacity", opacityLight * 1)

    local thresHighlight = self.attrsHighlight:GetVal("ADBE_Luma_Key_0002_1_5", self.progress)[1]
    self.propKeyHighlight:set("threshold", thresHighlight)

    local disXHighlight = self.attrsHighlight:GetVal("ADBE_Displacement_Map_0003_0_0", self.progress)[1] / 1080. * 1.2
    local disYHighlight = -self.attrsHighlight:GetVal("ADBE_Displacement_Map_0005_0_1", self.progress)[1] / 1080. * 1.2
    self.matHighlightDisplace:setVec2("offset", Amaz.Vector2f(disXHighlight, disYHighlight))

    self.matHighlightDisplace:setVec2("scale", Amaz.Vector2f(1.15, 1.15))
    self.matHighlightDisplace:setVec2("offsetBase", Amaz.Vector2f((629. - 540.) / 1080., -(791. - 540.) / 1080.))

    local turbulenceIntensityHighlight = self.attrsHighlight:GetVal("ADBE_IE_92959d1fb849aa97f8ff858_0001_0_2", self.progress)[1] / 100.
    self.propTurbulenceHighlight:set("size", turbulenceIntensityLight)

    self.videoHighlightDis:seekToTime(math.max(0, self.progress * 2.))

    self.animKira:seekToTime(math.max(0, self.progress * 2.))

    local deepGlowHighlight = self.attrsHighlight:GetVal("PEDG_0002_0_4", self.progress)[1]
    self.propDeepGlowHighlight:set("glow_intensity", deepGlowHighlight * .2 * 3)

    local opacityHighlight = self.attrsMain:GetVal("ADBE_Opacity_1_1", self.progress)[1] / 100.
    self.matBlendHighlight:setFloat("blendOpacity", opacityHighlight * 1)

    local opacityFilter = self.attrsMain:GetVal("ADBE_Opacity_1_0", self.progress)[1] / 100.
    self.matKira:setFloat("uniAlpha", opacityFilter)
end

function SeekModeScript:setParams(name, value)
    if name == "u_size" then
        -- local bgAspect = value.x / value.y
        -- local videoAspect = value.z / value.w
        -- if bgAspect > videoAspect then
        --     self.scaleCorrect = value.w / value.y
        -- else
        --     self.scaleCorrect = value.z / value.x
        -- end
        -- self.videoMat:setVec4("u_size", value)
        -- self.modelMat:setVec4("u_size", value)
        local FBS = Amaz.Vector2f(value.x, value.y)
        self.fxaaMat:setVec2("FBS", FBS)
        self.blendMat:setVec4("u_size", value)
    elseif name == "u_pos" then
        -- self.videoMat:setVec2("u_pos", value)
        -- self.blendMat:setVec2("u_pos", value)
        self.userPosition:set(value.x, value.y, 0)
    elseif name == "u_angle" then
        -- self.videoMat:setFloat("u_angle", value)
        -- self.blendMat:setFloat("u_angle", value)
        self.userEulerAngle:set(0, 0, value / math.pi * 180)
    elseif name == "u_scale" then
        -- self.videoMat:setFloat("u_scale", value)
        -- self.blendMat:setFloat("u_scale", value * self.scaleCorrect)
        self.userScale:set(value, value, 1)
    elseif name == "u_flipX" then
        self.videoMat:setFloat("u_flipX", value)
    elseif name == "u_flipY" then
        self.videoMat:setFloat("u_flipY", value)
    elseif name == "_alpha" then
        self.blendMat:setFloat("_alpha", value)
    end
end

function SeekModeScript:setDuration(duration)
    self.duration = duration
end

exports.SeekModeScript = SeekModeScript
return exports
