extensions [py matrix array] ;allows arrays and matrix

; Global variables
globals [
  num_image ;id of the image to be displayed
  max_id ;max_id to be displayed
  selected_folder ;if I selected or not, something
  track-me ;to save .csv
  file-name ;name to save
  dir

  next-pass-image ;n of the next tick to pass the image
  dif-pass-image
  mean-out-lung ;mean value inside
  std-out-lung ;

  formula_mean_right
  formula_mean_left
  formula_std_right
  formula_std_left
  min_idx_right
  min_idx_left
  max_idx_right
  max_idx_left

  lung ;which lung it is
  descend-ascend ;reading from descend way or ascend way
  pass ;number of times that pass all lung

  inside-lung
]

; Turtles variables
turtles-own [
  space_max ;space max that a turtle can travel
  color-red
]

; procedure to setup the simulation scenario
to setup
  clear-all

  py:setup py:python3
  (py:run
    "import os"
    "import numpy as np"
    "import imageio"
    "import random"
    "dir_py = os.path.abspath(os.path.dirname('__file__'))"
  )

  let root_dir py:runresult "dir_py"
  set num_image 1

  set dir (word root_dir "\\ct1\\")
  let str_num_image (word dir num_image ".png")

  let check user-directory
  if check != False [
      set dir check
      set str_num_image (word dir "\\" num_image ".png")
    ]

  py:set "dir_nlogo" dir
  (py:run
    "max_id = len(next(os.walk(dir_nlogo))[2]) / 2"
  )

  set max_id py:runresult "max_id"

  import-drawing str_num_image ;stupid error, I need to repeat the code 2times and then the image is printed
  import-drawing str_num_image

  ; turles initialization
  create-turtles 1
  ask turtles [
    set size 20
    set color red
    set shape "dot"
    setxy 220 -220 ;xcoord, ycoord
    set space_max 30
    set color-red TRUE
    py:set "space_max" space_max
  ]

  set track-me one-of turtles
  reset-ticks

  ; save name file
  let date (remove "-" (substring date-and-time 16 27))
  let time (remove "." remove ":" remove " " (substring date-and-time 0 15))
  set file-name (word root_dir "\\results\\file-" time "-" date ".csv")

  file-open file-name
  file-print "iteration,xcoord,ycoord,zcoord"
  file-close
  file-open file-name
  file-print Description
  file-close

  ; metrics related to images that it is needed to computer before everything
  (py:run
    "ct_color_1 = imageio.imread(dir_nlogo + '1_sectors.png')"
    "tam1 = np.size(ct_color_1,0)"
    "tam2 = np.size(ct_color_1,1)"
    "ct_colors = np.zeros([tam1,tam2,3,int(max_id)])"
    "valid_lung_slides = np.zeros(int(max_id))"
    "valid_right_slides = np.zeros(int(max_id))"
    "valid_left_slides = np.zeros(int(max_id))"
    "for i in range(int(max_id)): inter = imageio.imread(dir_nlogo + str(i+1)  + '_sectors.png'); ct_colors[:,:,:,i] = inter; valid_lung_slides[i] = np.max(inter); valid_right_slides[i] = np.max(inter[:,:,0]); valid_left_slides[i] = np.max(inter[:,:,1])"
    "out_slides = np.size(np.where(valid_lung_slides == 0),1)"

    "idx_right_slides = np.where(valid_right_slides > 0)"
    "min_idx_right = np.min(idx_right_slides)"
    "max_idx_right = np.max(idx_right_slides)"
    "dif_idx_right = max_idx_right - min_idx_right"

    "idx_left_slides = np.where(valid_left_slides > 0)"
    "min_idx_left = np.min(idx_left_slides)"
    "max_idx_left = np.max(idx_left_slides)"
    "dif_idx_left = max_idx_left - min_idx_left"

    "probabilities20 = np.array([[20,0.297716346494347,0.167216904181717,0.346545722585303,0.218929308306775,0,0,0,0.297716346494347,0,0,0,0.346545722585303]])"
    "probabilities30 = np.array([[30,0.186540864111143,0.156113686960323,0.14051885693063,0.150496723096041,0,0,0,0.186540864111143,0,0,0,0.14051885693063]])"
    "probabilities40 = np.array([[40,0.0845937669092631,0.0993204293877489,0.0976130155740453,0.123486244528316,0,0,0,0.0845937669092631,0,0,0,0.0976130155740453]])"
    "probabilities50 = np.array([[50,0.129078407986696,0.105595080848514,0.124774272033228,0.138408370735981,0,0,0,0.129078407986696,0,0,0,0.124774272033228]])"
    "probabilities60 = np.array([[60,0.145288636692003,0.213933603401254,0.217282472140479,0.250166050215797,0,0,0,0.145288636692003,0,0,0,0.217282472140479]])"
    "probabilities70 = np.array([[70,0.0869125491873637,0.153468443390578,0.0417215393273544,0.0714383121818442,0,0,0,0.0869125491873637,0,0,0,0.0417215393273544]])"
    "probabilities80 = np.array([[80,0.0698694286191841,0.104351851829864,0.0315441214089594,0.0470749909352457,0,0,0,0.0698694286191841,0,0,0,0.0315441214089594]])"
    "probabilities90 = np.array([[90,0.229806128962859,0.143546154924322,0.236701104678654,0.180339593219349,0,0,0,0.229806128962859,0,0,0,0.236701104678654]])"
    "probabilities100 = np.array([[100,0.313963863877633,0.269013252345817,0.216052997136018,0.215365108251175,0,0,0,0.313963863877633,0,0,0,0.216052997136018]])"
    "probabilities110 = np.array([[110,0.0386490041934267,0.0494271304312456,0.159696991226759,0.159888157169161,0,0,0,0.0386490041934267,0,0,0,0.159696991226759]])"
    "probabilities120 = np.array([[120,0.131763178963035,0.105511722842983,0.116487371776183,0.136227759877601,0,0,0,0.131763178963035,0,0,0,0.116487371776183]])"
    "probabilities130 = np.array([[130,0.157773710142167,0.194517238467622,0.219855306450941,0.220621139513044,0,0,0,0.157773710142167,0,0,0,0.219855306450941]])"
    "probabilities140 = np.array([[140,0.0548266728739257,0.115116426803917,0.0398654492090364,0.0615670988857528,0,0,0,0.0548266728739257,0,0,0,0.0398654492090364]])"
    "probabilities150 = np.array([[150,0.0732174409869539,0.122868074184094,0.0113407795224084,0.0259911430839164,0,0,0,0.0732174409869539,0,0,0,0.0113407795224084]])"
    "probabilities160 = np.array([[160,0.191916888024092,0.107963312962537,0.267101070358621,0.19302123282522,0,0,0,0.191916888024092,0,0,0,0.267101070358621]])"
    "probabilities170 = np.array([[170,0.276591149470761,0.272799466192551,0.209407525162127,0.216654555735992,0,0,0,0.276591149470761,0,0,0,0.209407525162127]])"
    "probabilities180 = np.array([[180,0.0855765116222738,0.091543396875813,0.185099826254412,0.185041956516672,0,0,0,0.0855765116222738,0,0,0,0.185099826254412]])"
    "probabilities190 = np.array([[190,0.170200311649725,0.109254282107826,0.108596950753017,0.12489940685082,0,0,0,0.170200311649725,0,0,0,0.108596950753017]])"
    "probabilities200 = np.array([[200,0.111915353996948,0.129125133977414,0.133943786509811,0.149812776044002,0,0,0,0.111915353996948,0,0,0,0.133943786509811]])"
    "probabilities210 = np.array([[210,0.0716875105968977,0.160764673202428,0.0648483360702039,0.081880644358471,0,0,0,0.0716875105968977,0,0,0,0.0648483360702039]])"
    "probabilities220 = np.array([[220,0.092112274639302,0.128549734681432,0.0310025048918082,0.0486894276688227,0,0,0,0.092112274639302,0,0,0,0.0310025048918082]])"

    "probabilities = np.concatenate((probabilities20, probabilities30, probabilities40, probabilities50, probabilities60, probabilities70, probabilities80), axis=0)"
    "probabilities = np.concatenate((probabilities, probabilities90, probabilities100, probabilities110, probabilities120, probabilities130, probabilities140, probabilities150), axis=0)"
    "probabilities = np.concatenate((probabilities, probabilities160, probabilities170, probabilities180, probabilities190, probabilities200, probabilities210, probabilities220), axis=0)"

  )

  set formula_mean_right (list (-0.00000007037505837 * ( py:runresult "dif_idx_right" / 279 ) ) (0.00004019779028 * ( py:runresult "dif_idx_right" / 279 ) ) (-0.007122360295 * ( py:runresult "dif_idx_right" / 279 ) ) (0.6072540765 * 1.3 * ( py:runresult "dif_idx_right" / 279 ) ))
  set formula_mean_left (list (-0.0000001162575198 * ( py:runresult "dif_idx_right" / 279 ) ) (0.00006145714153 * ( py:runresult "dif_idx_right" / 279 ) ) (-0.009789839553 * ( py:runresult "dif_idx_right" / 279 ) ) (0.6224039649 * 1.3 * ( py:runresult "dif_idx_right" / 279 ) ))
  set formula_std_right (list (-0.00000002670656088 * ( py:runresult "dif_idx_left" / 279 ) ) (0.00001449811053 * ( py:runresult "dif_idx_left" / 279 ) ) (-0.002810953445 * ( py:runresult "dif_idx_left" / 279 ) ) (0.4377108998 * ( py:runresult "dif_idx_left" / 279 ) ))
  set formula_std_left (list (-0.00000002912425341 * ( py:runresult "dif_idx_left" / 279 ) ) (0.000016683754206 * ( py:runresult "dif_idx_left" / 279 ) ) (-0.003116448079 * ( py:runresult "dif_idx_left" / 279 ) ) (0.367328411 * ( py:runresult "dif_idx_left" / 279 ) ))

  let out_lung ((py:runresult "out_slides") * 16)
  set mean-out-lung 35.01694788273617 / out_lung
  set std-out-lung 22.564015659625785 / out_lung

  set min_idx_right ( py:runresult "min_idx_right" + 1)
  set max_idx_right ( py:runresult "max_idx_right" + 1)
  set min_idx_left ( py:runresult "min_idx_left" + 1)
  set max_idx_left ( py:runresult "max_idx_left" + 1)

  set next-pass-image round(((mean-out-lung) + (((random 2) * 2) - 1) * (random-float std-out-lung)) * 90)
  set dif-pass-image next-pass-image

  set descend-ascend TRUE
  set pass 0

  set lung "right"
  set inside-lung FALSE

end

; procedute to run the simulation
to go

  ; change image
  ifelse (ticks = next-pass-image) [

    ;set num_image (num_image + 1)

    ifelse (pass < 2) and (descend-ascend) and (num_image >= (get-value-type "min_idx") - 2) and (num_image <= (get-value-type "max_idx") + 5)
    [
      ;set next-pass-image (random 11 + next-pass-image + 60 - 5)
      let param1_mean (item 0 (get-value-type "formula_mean")) * ((num_image + 1 - (get-value-type "min_idx") ) ^ 3)
      let param2_mean (item 1 (get-value-type "formula_mean")) * ((num_image + 1 - (get-value-type "min_idx") ) ^ 2)
      let param3_mean (item 2 (get-value-type "formula_mean")) * ((num_image + 1 - (get-value-type "min_idx") ) ^ 1)
      let param4_mean (item 3 (get-value-type "formula_mean"))
      let param_sum_mean (param1_mean + param2_mean + param3_mean + param4_mean)

      let param1_std (item 0 (get-value-type "formula_std")) * ((num_image + 1 - (get-value-type "min_idx")) ^ 3)
      let param2_std (item 1 (get-value-type "formula_std")) * ((num_image + 1 - (get-value-type "min_idx")) ^ 2)
      let param3_std (item 2 (get-value-type "formula_std")) * ((num_image + 1 - (get-value-type "min_idx")) ^ 1)
      let param4_std (item 3 (get-value-type "formula_std"))
      let param_sum_std ((random-float(param1_std + param2_std + param3_std + param4_std)) * (((random 2) * 2) - 1))

      set dif-pass-image (max list 1 random((param_sum_mean + param_sum_std) * 90))
      set next-pass-image (next-pass-image + dif-pass-image)

    ]
    [
      ifelse (descend-ascend) and (num_image > (get-value-type "max_idx") + 5)
      [
        set dif-pass-image (round(((mean-out-lung) + (((random 2) * 2) - 1) * (random-float std-out-lung)) * 90))
        set next-pass-image (next-pass-image + dif-pass-image)
        set descend-ascend FALSE

        set pass (pass + 1)

        if (pass = 2) [
          let remaining (ticks / 0.85)
        ]

      ]
      [
        ifelse (descend-ascend = FALSE) and (num_image < (get-value-type "min_idx") - 2)
        [
          set dif-pass-image (round(((mean-out-lung) + (((random 2) * 2) - 1) * (random-float std-out-lung)) * 90))
          set next-pass-image (next-pass-image + dif-pass-image)
          set descend-ascend TRUE

          ifelse (lung = "right")[
            set lung "left"
          ]
          [
            set lung "right"
          ]

        ]
        [
          ifelse (pass >= 2) and (descend-ascend) and (num_image >= (get-value-type "min_idx") - 2) and (num_image <= (get-value-type "max_idx") + 5)
          [
            let param1_mean (item 0 (get-value-type "formula_mean")) * ((num_image + 1 - (get-value-type "min_idx")) ^ 3)
            let param2_mean (item 1 (get-value-type "formula_mean")) * ((num_image + 1 - (get-value-type "min_idx")) ^ 2)
            let param3_mean (item 2 (get-value-type "formula_mean")) * ((num_image + 1 - (get-value-type "min_idx")) ^ 1)
            let param4_mean (item 3 (get-value-type "formula_mean")) * (2 / 3)
            let param_sum_mean (param1_mean + param2_mean + param3_mean + param4_mean)

            let param1_std (item 0 (get-value-type "formula_std")) * ((num_image + 1 - (get-value-type "min_idx")) ^ 3)
            let param2_std (item 1 (get-value-type "formula_std")) * ((num_image + 1 - (get-value-type "min_idx")) ^ 2)
            let param3_std (item 2 (get-value-type "formula_std")) * ((num_image + 1 - (get-value-type "min_idx")) ^ 1)
            let param4_std (item 3 (get-value-type "formula_std")) * (2 / 3)
            let param_sum_std ((random-float(param1_std + param2_std + param3_std + param4_std)) * (((random 2) * 2) - 1))

            set dif-pass-image (max list 1 random((param_sum_mean + param_sum_std) * 90))
            set next-pass-image (next-pass-image + dif-pass-image)

          ]
          [

            set dif-pass-image ( round(((mean-out-lung) + (((random 2) * 2) - 1) * (random-float std-out-lung)) * 90) )
            set next-pass-image (next-pass-image + dif-pass-image)

          ]
        ]
      ]
    ]

    ifelse (descend-ascend)[
      set num_image (num_image + 1)
      let str_num_image (word dir "\\" num_image ".png")
      import-drawing str_num_image
    ]
    [
      set num_image (num_image - 1)
      let str_num_image (word dir "\\" num_image ".png")
      import-drawing str_num_image
    ]
  ]
  [
    ifelse (num_image >= (get-value-type "min_idx")) and (num_image <= (get-value-type "max_idx"))
    [
      set inside-lung TRUE
    ]
    [
      set inside-lung FALSE
    ]

    ifelse (inside-lung) and (descend-ascend)[
      ask turtles [lung-movement]
    ][
      ask turtles [random-movement]
    ]
  ]

  ask track-me [
    file-open file-name
    file-print (word ticks "," xcor "," ycor "," num_image "")
    file-close
  ]

  if (pass = 3)[
    stop
  ]

  tick

end

; MOVEMENTS INSIDE LUNG
to lung-movement
  ;let temp [xcor] of turtles

  let row (- ycor)
  let col (xcor)
  let page (num_image - 1)

  let i_rgb 1
  if (lung = "right")
  [
    set i_rgb 0
  ]

  py:set "row" row
  py:set "col" col
  py:set "page" page
  py:set "i_rgb" i_rgb

  (py:run
    "pixel_value = np.max(ct_colors[row,col,i_rgb,page])"
    )
  let pixel_value py:runresult "pixel_value"

  ifelse pixel_value = 0 [
    (py:run
      "idx = np.where(ct_colors[:,:,i_rgb,page] > 0); idx0 = idx[0]; idx1 = idx[1]; idx0_sub = idx0 - row; idx1_sub = idx1 - col; idx2 = ((idx0_sub**2) + (idx1_sub**2))**(1/2); amin = np.argmin(idx2)"
      "idx_row = row - idx0[amin]; idx_col = col - idx1[amin];"
      "signal = 1 if (idx_row >= 0) & (idx_col >= 0) else 2 if (idx_row >= 0) & (idx_col <= 0) else 3 if (idx_row <= 0) & (idx_col <= 0) else 4"
      )

    let signal py:runresult "signal"
    let idx_row py:runresult "idx_row"
    let idx_col py:runresult "idx_col"

    let sum_x min list (random space_max + 1) (abs idx_col)
    let sum_y min list (random space_max + 1) (abs idx_row)

    ifelse signal = 1
    [
      set sum_x (- sum_x)
      set sum_y sum_y
    ]
    [
      ifelse signal = 4
      [
        set sum_x (- sum_x)
        set sum_y (- sum_y)
      ]
      [
        if signal = 3
        [
          set sum_x sum_x
          set sum_y (- sum_y)
        ]
      ]
    ]

    let x_coord (xcor + sum_x)
    let y_coord (ycor + sum_y)

;    show sum_x
;    show sum_y

    setxy x_coord y_coord
  ]
  [
    (py:run
      "un = np.unique(ct_colors[:,:,i_rgb,page]); tam = len(un)"
      )
    let tam py:runresult "tam"

    ifelse (tam = 2) or (pass >= 2)
    [
      (py:run
        "random_array = np.random.rand(tam1,tam2);"
        "inter = (ct_colors[:,:,i_rgb,page] > 0) * random_array;"
        "amax_y = np.argmax(np.max(inter[row - int(space_max/2):row + int(space_max/2), col - int(space_max/2):col + int(space_max/2)], axis=1))"
        "amax_x = np.argmax(np.max(inter[row - int(space_max/2):row + int(space_max/2), col - int(space_max/2):col + int(space_max/2)], axis=0))"
      )

      let amax_x py:runresult "amax_x"
      let amax_y py:runresult "amax_y"

      let x_coord (xcor + (amax_x - 15))
      let y_coord (ycor - (amax_y - 15))

      setxy x_coord y_coord
      set color red
      if (color-red = FALSE)
      [
        set color-red TRUE
      ]
    ]
    [

      (py:run
        "un = np.unique(ct_colors[:,:,2,page] * (ct_colors[:,:,i_rgb,page] > 0)); tam = len(un)"
        "pixel_value = np.max(ct_colors[row,col,2,page])"
        )
      set tam py:runresult "tam"
      set pixel_value py:runresult "pixel_value"

      ifelse (tam = 1)
      [

        ifelse (lung = "right")
        [
          py:set "s_lung" 0
        ]
        [
          py:set "s_lung" 4
        ]

        (py:run
          "pixel_value = np.max(ct_colors[row,col,i_rgb,page])"
          "row_prob = int((pixel_value - 20)/10)"
          "count_i = 0 if (row_prob < 7) else 7 if (row_prob < 14) else 14"
          "probabilities[count_i:count_i+7, 5+s_lung] += 1"
          "probabilities[row_prob, 6+s_lung] += 1"
          "probabilities[row_prob, 7+s_lung] = probabilities[row_prob, 6+s_lung]/probabilities[row_prob, 5+s_lung]"
          "probabilities[row_prob, 8+s_lung] = probabilities[row_prob, 1+int(s_lung/2)] - probabilities[row_prob, 7+s_lung]"
          "neg_out = (1 - (ct_colors[row - int(space_max/2):row + 1 + int(space_max/2), col - int(space_max/2):col + 1 + int(space_max/2),i_rgb,page] > 0)) * (-100000)"
          "neg_out = neg_out.flatten()"
          "inter = ct_colors[row - int(space_max/2):row + 1 + int(space_max/2), col - int(space_max/2):col + 1 + int(space_max/2),i_rgb,page]"
          "inter2 = inter.flatten()"
          "for i in range(len(inter2)): inter2[i] =  neg_out[i] + probabilities[int((inter2[i] - 20)/10), 8+s_lung] + ((random.randint(0, 1) * 2) - 1) * random.uniform(0,(probabilities[int((inter2[i] - 20)/10), 2+int(s_lung/2)]))"
          "inter3 = np.reshape(inter2, (space_max+1, space_max+1))"
          "amax_y = np.argmax(np.max(inter3, axis=1))"
          "amax_x = np.argmax(np.max(inter3, axis=0))"
        )

          let amax_x py:runresult "amax_x"
          let amax_y py:runresult "amax_y"

          let x_coord (xcor + (amax_x - 15))
          let y_coord (ycor - (amax_y - 15))

          setxy x_coord y_coord
          set color red

          if (color-red = FALSE)
          [
            set color-red TRUE
          ]

      ]
      [

          (py:run
            "idx = np.where(ct_colors[:,:,2,page] > 0); idx0 = idx[0]; idx1 = idx[1]; idx0_sub = idx0 - row; idx1_sub = idx1 - col; idx2 = ((idx0_sub**2) + (idx1_sub**2))**(1/2); amin = np.argmin(idx2)"
            "idx_row = row - idx0[amin]; idx_col = col - idx1[amin];"
            "signal = 1 if (idx_row >= 0) & (idx_col >= 0) else 2 if (idx_row >= 0) & (idx_col <= 0) else 3 if (idx_row <= 0) & (idx_col <= 0) else 4"
            )

          let signal py:runresult "signal"
          let idx_row py:runresult "idx_row"
          let idx_col py:runresult "idx_col"

          let sum_x min list (random space_max + 1) (abs idx_col + 1)
          let sum_y min list (random space_max + 1) (abs idx_row + 1)

          ifelse ((abs idx_col + 1) < space_max) and ((abs idx_row + 1) < space_max)
          [
            (py:run
              "random_array = np.random.rand(tam1,tam2);"
              "inter = (ct_colors[:,:,2,page] / np.max(ct_colors[:,:,2,page])) * random_array;"
              "amax_y = np.argmax(np.max(inter[row - int(space_max/2):row + int(space_max/2), col - int(space_max/2):col + int(space_max/2)], axis=1))"
              "amax_x = np.argmax(np.max(inter[row - int(space_max/2):row + int(space_max/2), col - int(space_max/2):col + int(space_max/2)], axis=0))"
            )

            let amax_x py:runresult "amax_x"
            let amax_y py:runresult "amax_y"

            let x_coord (xcor + (amax_x - 15))
            let y_coord (ycor - (amax_y - 15))

            setxy x_coord y_coord
            set color yellow

            if (color-red = TRUE) or (ticks = next-pass-image - 2 - dif-pass-image)
            [
              set color-red FALSE
              set next-pass-image (next-pass-image + (dif-pass-image * 6))
              set dif-pass-image (dif-pass-image * 7)
            ]
          ]
          [
            ifelse signal = 1
            [
              set sum_x (- sum_x)
              set sum_y sum_y
            ]
            [
              ifelse signal = 4
              [
                set sum_x (- sum_x)
                set sum_y (- sum_y)
              ]
              [
                if signal = 3
                [
                  set sum_x sum_x
                  set sum_y (- sum_y)
                ]
              ]
            ]

            let x_coord (xcor + sum_x)
            let y_coord (ycor + sum_y)

        ;    show sum_x
        ;    show sum_y

            setxy x_coord y_coord
        ]
      ]
    ]
  ]

end

; UNTIL THE BOTTOM IS TO SET RANDOM MOVEMENTS
to-report get-value-type [value]

  if (value = "formula_mean") and (lung = "right")
  [
    report formula_mean_right
  ]

  if (value = "formula_mean") and (lung = "left")
  [
    report formula_mean_left
  ]

  if (value = "formula_std") and (lung = "right")
  [
    report formula_std_right
  ]

  if (value = "formula_std") and (lung = "left")
  [
    report formula_std_left
  ]

  if (value = "min_idx") and (lung = "right")
  [
    report min_idx_right
  ]

  if (value = "min_idx") and (lung = "left")
  [
    report min_idx_left
  ]

  if (value = "max_idx") and (lung = "right")
  [
    report max_idx_right
  ]

  if (value = "max_idx") and (lung = "left")
  [
    report max_idx_left
  ]

end

; algorithm to travel information
to random-movement

  ; wait 1

  ; set random space
  let space random (int (space_max * 2) + 1)
  if (( space mod 2 ) = 0) [set space (space + 1)]

  ; space cannot be 0
  if (space > 0) [

    ; initialization matrix to find movement
    let random_matrix (fill-matrix space space)
    let max_coord max-matrix random_matrix space

    ;row y
    ;column x
    let x_coord (xcor + (array:item max_coord 1) - ((space - 1) / 2))
    let y_coord (ycor - (array:item max_coord 0) + ((space - 1) / 2))

    ; limits restrictions
    if (x_coord < 0) [set x_coord (- x_coord)]
    if (y_coord > 0) [set y_coord (- y_coord)]
    if (x_coord > 511) [set x_coord (511 - (x_coord - 511))]
    if (y_coord < -511) [set y_coord (-511 + (-511 - y_coord))]
    setxy x_coord y_coord
  ]

end

to-report fill-matrix [n m]
  report matrix:from-row-list n-values n [n-values m [random-float 1]]
end

; find max indexes of a matrix
to-report max-matrix [my_matrix_ space_]

  let pos array:from-list n-values 2 [0]
  let r 0
  let c 0

  let maximum matrix:get my_matrix_ 0 0
  while [(r < space_)]
  [ while [(c < space_)]
    [let inter matrix:get my_matrix_ r c
      if (inter >= maximum)[
      set maximum inter
      array:set pos 0 r
      array:set pos 1 c
      ]
      set c (c + 1)
    ]
    set c 0
    set r (r + 1)
  ]

  report pos

end
@#$#@#$#@
GRAPHICS-WINDOW
206
11
795
601
-1
-1
1.133
1
10
1
1
1
0
0
0
1
0
512
-512
0
0
0
0
ticks
30.0

BUTTON
11
47
192
80
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
12
192
45
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
11
82
192
142
Description
NIL
1
0
String

TEXTBOX
896
126
1046
144
NIL
11
0.0
1

PLOT
810
12
1147
303
X Coordinate
Time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13210332 true "" "ask turtles[ plotxy ticks xcor ]"

PLOT
810
308
1147
600
Y Coordinate
Time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13210332 true "" "ask turtles[ plotxy ticks (- ycor) ]"

PLOT
1155
12
1479
303
Z Coordinate
NIL
Time
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13210332 true "" "ask turtles[ plotxy ticks num_image ]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
