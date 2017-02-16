(in-package :cl-user)
(defpackage :lem.term
  (:use :cl)
  (:export :with-raw
           :get-color-pair
           :background-mode
           :term-init
           :term-finalize
           :term-set-tty))
(in-package :lem.term)

(cffi:defcvar ("COLOR_PAIRS" *COLOR-PAIRS* :library charms/ll::libcurses) :int)

(defvar *colors*)
(defvar *color-pair-table* (make-hash-table :test 'equal))
(defvar *pair-counter* 0)

(defstruct color
  number
  name
  r
  g
  b)

(defun add-color (number name r g b &optional builtin)
  (declare (ignore builtin))
  (flet ((f (n) (round (* n 1000/255))))
    (charms/ll:init-color number (f r) (f g) (f b)))
  (vector-push-extend (make-color :number number :name name :r r :g g :b b)
                      *colors*))

(defun init-pair (fg-color bg-color)
  (incf *pair-counter*)
  (charms/ll:init-pair *pair-counter* fg-color bg-color)
  (setf (gethash (cons fg-color bg-color) *color-pair-table*)
        (charms/ll:color-pair *pair-counter*)))

(defun init-colors ()
  (when (/= 0 (charms/ll:has-colors))
    (charms/ll:start-color)
    (clrhash *color-pair-table*)
    (setf *colors* (make-array 0 :fill-pointer 0 :adjustable t))
    (add-color charms/ll:color_black "black" #x00 #x00 #x00 t)
    (add-color charms/ll:color_red "red" #xcd #x00 #x00 t)
    (add-color charms/ll:color_green "green" #x00 #xcd #x00 t)
    (add-color charms/ll:color_yellow "yellow" #xcd #xcd #x00 t)
    (add-color charms/ll:color_blue "blue" #x00 #x00 #xee t)
    (add-color charms/ll:color_magenta "magenta" #xcd #x00 #xcd t)
    (add-color charms/ll:color_cyan "cyan" #x00 #xcd #xcd t)
    (add-color charms/ll:color_white "white" #xe5 #xe5 #xe5 t)
    (when (<= 16 charms/ll:*colors*)
      (add-color 8 "brightblack" #x7f #x7f #x7f)
      (add-color 9 "brightred" #xff #x00 #x00)
      (add-color 10 "brightgreen" #x00 #xff #x00)
      (add-color 11 "brightyellow" #xff #xff #x00)
      (add-color 12 "brightblue" #x5c #x5c #xff)
      (add-color 13 "brightmagenta" #xff #x00 #xff)
      (add-color 14 "brightcyan" #x00 #xff #xff)
      (add-color 15 "brightwhite" #xff #xff #xff))
    (when (<= 256 charms/ll:*colors*)
      (add-color 16 "color-16" #x00 #x00 #x00)
      (add-color 17 "color-17" #x00 #x00 #x5f)
      (add-color 18 "color-18" #x00 #x00 #x87)
      (add-color 19 "color-19" #x00 #x00 #xaf)
      (add-color 20 "color-20" #x00 #x00 #xd7)
      (add-color 21 "color-21" #x00 #x00 #xff)
      (add-color 22 "color-22" #x00 #x5f #x00)
      (add-color 23 "color-23" #x00 #x5f #x5f)
      (add-color 24 "color-24" #x00 #x5f #x87)
      (add-color 25 "color-25" #x00 #x5f #xaf)
      (add-color 26 "color-26" #x00 #x5f #xd7)
      (add-color 27 "color-27" #x00 #x5f #xff)
      (add-color 28 "color-28" #x00 #x87 #x00)
      (add-color 29 "color-29" #x00 #x87 #x5f)
      (add-color 30 "color-30" #x00 #x87 #x87)
      (add-color 31 "color-31" #x00 #x87 #xaf)
      (add-color 32 "color-32" #x00 #x87 #xd7)
      (add-color 33 "color-33" #x00 #x87 #xff)
      (add-color 34 "color-34" #x00 #xaf #x00)
      (add-color 35 "color-35" #x00 #xaf #x5f)
      (add-color 36 "color-36" #x00 #xaf #x87)
      (add-color 37 "color-37" #x00 #xaf #xaf)
      (add-color 38 "color-38" #x00 #xaf #xd7)
      (add-color 39 "color-39" #x00 #xaf #xff)
      (add-color 40 "color-40" #x00 #xd7 #x00)
      (add-color 41 "color-41" #x00 #xd7 #x5f)
      (add-color 42 "color-42" #x00 #xd7 #x87)
      (add-color 43 "color-43" #x00 #xd7 #xaf)
      (add-color 44 "color-44" #x00 #xd7 #xd7)
      (add-color 45 "color-45" #x00 #xd7 #xff)
      (add-color 46 "color-46" #x00 #xff #x00)
      (add-color 47 "color-47" #x00 #xff #x5f)
      (add-color 48 "color-48" #x00 #xff #x87)
      (add-color 49 "color-49" #x00 #xff #xaf)
      (add-color 50 "color-50" #x00 #xff #xd7)
      (add-color 51 "color-51" #x00 #xff #xff)
      (add-color 52 "color-52" #x5f #x00 #x00)
      (add-color 53 "color-53" #x5f #x00 #x5f)
      (add-color 54 "color-54" #x5f #x00 #x87)
      (add-color 55 "color-55" #x5f #x00 #xaf)
      (add-color 56 "color-56" #x5f #x00 #xd7)
      (add-color 57 "color-57" #x5f #x00 #xff)
      (add-color 58 "color-58" #x5f #x5f #x00)
      (add-color 59 "color-59" #x5f #x5f #x5f)
      (add-color 60 "color-60" #x5f #x5f #x87)
      (add-color 61 "color-61" #x5f #x5f #xaf)
      (add-color 62 "color-62" #x5f #x5f #xd7)
      (add-color 63 "color-63" #x5f #x5f #xff)
      (add-color 64 "color-64" #x5f #x87 #x00)
      (add-color 65 "color-65" #x5f #x87 #x5f)
      (add-color 66 "color-66" #x5f #x87 #x87)
      (add-color 67 "color-67" #x5f #x87 #xaf)
      (add-color 68 "color-68" #x5f #x87 #xd7)
      (add-color 69 "color-69" #x5f #x87 #xff)
      (add-color 70 "color-70" #x5f #xaf #x00)
      (add-color 71 "color-71" #x5f #xaf #x5f)
      (add-color 72 "color-72" #x5f #xaf #x87)
      (add-color 73 "color-73" #x5f #xaf #xaf)
      (add-color 74 "color-74" #x5f #xaf #xd7)
      (add-color 75 "color-75" #x5f #xaf #xff)
      (add-color 76 "color-76" #x5f #xd7 #x00)
      (add-color 77 "color-77" #x5f #xd7 #x5f)
      (add-color 78 "color-78" #x5f #xd7 #x87)
      (add-color 79 "color-79" #x5f #xd7 #xaf)
      (add-color 80 "color-80" #x5f #xd7 #xd7)
      (add-color 81 "color-81" #x5f #xd7 #xff)
      (add-color 82 "color-82" #x5f #xff #x00)
      (add-color 83 "color-83" #x5f #xff #x5f)
      (add-color 84 "color-84" #x5f #xff #x87)
      (add-color 85 "color-85" #x5f #xff #xaf)
      (add-color 86 "color-86" #x5f #xff #xd7)
      (add-color 87 "color-87" #x5f #xff #xff)
      (add-color 88 "color-88" #x87 #x00 #x00)
      (add-color 89 "color-89" #x87 #x00 #x5f)
      (add-color 90 "color-90" #x87 #x00 #x87)
      (add-color 91 "color-91" #x87 #x00 #xaf)
      (add-color 92 "color-92" #x87 #x00 #xd7)
      (add-color 93 "color-93" #x87 #x00 #xff)
      (add-color 94 "color-94" #x87 #x5f #x00)
      (add-color 95 "color-95" #x87 #x5f #x5f)
      (add-color 96 "color-96" #x87 #x5f #x87)
      (add-color 97 "color-97" #x87 #x5f #xaf)
      (add-color 98 "color-98" #x87 #x5f #xd7)
      (add-color 99 "color-99" #x87 #x5f #xff)
      (add-color 100 "color-100" #x87 #x87 #x00)
      (add-color 101 "color-101" #x87 #x87 #x5f)
      (add-color 102 "color-102" #x87 #x87 #x87)
      (add-color 103 "color-103" #x87 #x87 #xaf)
      (add-color 104 "color-104" #x87 #x87 #xd7)
      (add-color 105 "color-105" #x87 #x87 #xff)
      (add-color 106 "color-106" #x87 #xaf #x00)
      (add-color 107 "color-107" #x87 #xaf #x5f)
      (add-color 108 "color-108" #x87 #xaf #x87)
      (add-color 109 "color-109" #x87 #xaf #xaf)
      (add-color 110 "color-110" #x87 #xaf #xd7)
      (add-color 111 "color-111" #x87 #xaf #xff)
      (add-color 112 "color-112" #x87 #xd7 #x00)
      (add-color 113 "color-113" #x87 #xd7 #x5f)
      (add-color 114 "color-114" #x87 #xd7 #x87)
      (add-color 115 "color-115" #x87 #xd7 #xaf)
      (add-color 116 "color-116" #x87 #xd7 #xd7)
      (add-color 117 "color-117" #x87 #xd7 #xff)
      (add-color 118 "color-118" #x87 #xff #x00)
      (add-color 119 "color-119" #x87 #xff #x5f)
      (add-color 120 "color-120" #x87 #xff #x87)
      (add-color 121 "color-121" #x87 #xff #xaf)
      (add-color 122 "color-122" #x87 #xff #xd7)
      (add-color 123 "color-123" #x87 #xff #xff)
      (add-color 124 "color-124" #xaf #x00 #x00)
      (add-color 125 "color-125" #xaf #x00 #x5f)
      (add-color 126 "color-126" #xaf #x00 #x87)
      (add-color 127 "color-127" #xaf #x00 #xaf)
      (add-color 128 "color-128" #xaf #x00 #xd7)
      (add-color 129 "color-129" #xaf #x00 #xff)
      (add-color 130 "color-130" #xaf #x5f #x00)
      (add-color 131 "color-131" #xaf #x5f #x5f)
      (add-color 132 "color-132" #xaf #x5f #x87)
      (add-color 133 "color-133" #xaf #x5f #xaf)
      (add-color 134 "color-134" #xaf #x5f #xd7)
      (add-color 135 "color-135" #xaf #x5f #xff)
      (add-color 136 "color-136" #xaf #x87 #x00)
      (add-color 137 "color-137" #xaf #x87 #x5f)
      (add-color 138 "color-138" #xaf #x87 #x87)
      (add-color 139 "color-139" #xaf #x87 #xaf)
      (add-color 140 "color-140" #xaf #x87 #xd7)
      (add-color 141 "color-141" #xaf #x87 #xff)
      (add-color 142 "color-142" #xaf #xaf #x00)
      (add-color 143 "color-143" #xaf #xaf #x5f)
      (add-color 144 "color-144" #xaf #xaf #x87)
      (add-color 145 "color-145" #xaf #xaf #xaf)
      (add-color 146 "color-146" #xaf #xaf #xd7)
      (add-color 147 "color-147" #xaf #xaf #xff)
      (add-color 148 "color-148" #xaf #xd7 #x00)
      (add-color 149 "color-149" #xaf #xd7 #x5f)
      (add-color 150 "color-150" #xaf #xd7 #x87)
      (add-color 151 "color-151" #xaf #xd7 #xaf)
      (add-color 152 "color-152" #xaf #xd7 #xd7)
      (add-color 153 "color-153" #xaf #xd7 #xff)
      (add-color 154 "color-154" #xaf #xff #x00)
      (add-color 155 "color-155" #xaf #xff #x5f)
      (add-color 156 "color-156" #xaf #xff #x87)
      (add-color 157 "color-157" #xaf #xff #xaf)
      (add-color 158 "color-158" #xaf #xff #xd7)
      (add-color 159 "color-159" #xaf #xff #xff)
      (add-color 160 "color-160" #xd7 #x00 #x00)
      (add-color 161 "color-161" #xd7 #x00 #x5f)
      (add-color 162 "color-162" #xd7 #x00 #x87)
      (add-color 163 "color-163" #xd7 #x00 #xaf)
      (add-color 164 "color-164" #xd7 #x00 #xd7)
      (add-color 165 "color-165" #xd7 #x00 #xff)
      (add-color 166 "color-166" #xd7 #x5f #x00)
      (add-color 167 "color-167" #xd7 #x5f #x5f)
      (add-color 168 "color-168" #xd7 #x5f #x87)
      (add-color 169 "color-169" #xd7 #x5f #xaf)
      (add-color 170 "color-170" #xd7 #x5f #xd7)
      (add-color 171 "color-171" #xd7 #x5f #xff)
      (add-color 172 "color-172" #xd7 #x87 #x00)
      (add-color 173 "color-173" #xd7 #x87 #x5f)
      (add-color 174 "color-174" #xd7 #x87 #x87)
      (add-color 175 "color-175" #xd7 #x87 #xaf)
      (add-color 176 "color-176" #xd7 #x87 #xd7)
      (add-color 177 "color-177" #xd7 #x87 #xff)
      (add-color 178 "color-178" #xd7 #xaf #x00)
      (add-color 179 "color-179" #xd7 #xaf #x5f)
      (add-color 180 "color-180" #xd7 #xaf #x87)
      (add-color 181 "color-181" #xd7 #xaf #xaf)
      (add-color 182 "color-182" #xd7 #xaf #xd7)
      (add-color 183 "color-183" #xd7 #xaf #xff)
      (add-color 184 "color-184" #xd7 #xd7 #x00)
      (add-color 185 "color-185" #xd7 #xd7 #x5f)
      (add-color 186 "color-186" #xd7 #xd7 #x87)
      (add-color 187 "color-187" #xd7 #xd7 #xaf)
      (add-color 188 "color-188" #xd7 #xd7 #xd7)
      (add-color 189 "color-189" #xd7 #xd7 #xff)
      (add-color 190 "color-190" #xd7 #xff #x00)
      (add-color 191 "color-191" #xd7 #xff #x5f)
      (add-color 192 "color-192" #xd7 #xff #x87)
      (add-color 193 "color-193" #xd7 #xff #xaf)
      (add-color 194 "color-194" #xd7 #xff #xd7)
      (add-color 195 "color-195" #xd7 #xff #xff)
      (add-color 196 "color-196" #xff #x00 #x00)
      (add-color 197 "color-197" #xff #x00 #x5f)
      (add-color 198 "color-198" #xff #x00 #x87)
      (add-color 199 "color-199" #xff #x00 #xaf)
      (add-color 200 "color-200" #xff #x00 #xd7)
      (add-color 201 "color-201" #xff #x00 #xff)
      (add-color 202 "color-202" #xff #x5f #x00)
      (add-color 203 "color-203" #xff #x5f #x5f)
      (add-color 204 "color-204" #xff #x5f #x87)
      (add-color 205 "color-205" #xff #x5f #xaf)
      (add-color 206 "color-206" #xff #x5f #xd7)
      (add-color 207 "color-207" #xff #x5f #xff)
      (add-color 208 "color-208" #xff #x87 #x00)
      (add-color 209 "color-209" #xff #x87 #x5f)
      (add-color 210 "color-210" #xff #x87 #x87)
      (add-color 211 "color-211" #xff #x87 #xaf)
      (add-color 212 "color-212" #xff #x87 #xd7)
      (add-color 213 "color-213" #xff #x87 #xff)
      (add-color 214 "color-214" #xff #xaf #x00)
      (add-color 215 "color-215" #xff #xaf #x5f)
      (add-color 216 "color-216" #xff #xaf #x87)
      (add-color 217 "color-217" #xff #xaf #xaf)
      (add-color 218 "color-218" #xff #xaf #xd7)
      (add-color 219 "color-219" #xff #xaf #xff)
      (add-color 220 "color-220" #xff #xd7 #x00)
      (add-color 221 "color-221" #xff #xd7 #x5f)
      (add-color 222 "color-222" #xff #xd7 #x87)
      (add-color 223 "color-223" #xff #xd7 #xaf)
      (add-color 224 "color-224" #xff #xd7 #xd7)
      (add-color 225 "color-225" #xff #xd7 #xff)
      (add-color 226 "color-226" #xff #xff #x00)
      (add-color 227 "color-227" #xff #xff #x5f)
      (add-color 228 "color-228" #xff #xff #x87)
      (add-color 229 "color-229" #xff #xff #xaf)
      (add-color 230 "color-230" #xff #xff #xd7)
      (add-color 231 "color-231" #xff #xff #xff)
      (add-color 232 "color-232" #x08 #x08 #x08)
      (add-color 233 "color-233" #x12 #x12 #x12)
      (add-color 234 "color-234" #x1c #x1c #x1c)
      (add-color 235 "color-235" #x26 #x26 #x26)
      (add-color 236 "color-236" #x30 #x30 #x30)
      (add-color 237 "color-237" #x3a #x3a #x3a)
      (add-color 238 "color-238" #x44 #x44 #x44)
      (add-color 239 "color-239" #x4e #x4e #x4e)
      (add-color 240 "color-240" #x58 #x58 #x58)
      (add-color 241 "color-241" #x62 #x62 #x62)
      (add-color 242 "color-242" #x6c #x6c #x6c)
      (add-color 243 "color-243" #x76 #x76 #x76)
      (add-color 244 "color-244" #x80 #x80 #x80)
      (add-color 245 "color-245" #x8a #x8a #x8a)
      (add-color 246 "color-246" #x94 #x94 #x94)
      (add-color 247 "color-247" #x9e #x9e #x9e)
      (add-color 248 "color-248" #xa8 #xa8 #xa8)
      (add-color 249 "color-249" #xb2 #xb2 #xb2)
      (add-color 250 "color-250" #xbc #xbc #xbc)
      (add-color 251 "color-251" #xc6 #xc6 #xc6)
      (add-color 252 "color-252" #xd0 #xd0 #xd0)
      (add-color 253 "color-253" #xda #xda #xda)
      (add-color 254 "color-254" #xe4 #xe4 #xe4)
      (add-color 255 "color-255" #xee #xee #xee))
    (set-default-color nil nil)
    t))

(defun get-color (string)
  (let* ((string (string-trim " " string))
         (color (cond ((zerop (length string))
                       nil)
                      ((and (char= #\# (aref string 0))
                            (= 7 (length string)))
                       (let ((r (parse-integer string :start 1 :end 3 :radix 16 :junk-allowed t))
                             (g (parse-integer string :start 3 :end 5 :radix 16 :junk-allowed t))
                             (b (parse-integer string :start 5 :end 7 :radix 16 :junk-allowed t)))
                         (if (not (and r g b))
                             nil
                             (let (found-color
                                   (min most-positive-fixnum))
                               (loop :for color :across *colors*
                                     :do (let ((dr (- (color-r color) r))
                                               (dg (- (color-g color) g))
                                               (db (- (color-b color) b)))
                                           (let ((dist (+ (* dr dr) (* dg dg) (* db db))))
                                             (when (< dist min)
                                               (setf min dist)
                                               (setf found-color color)))))
                               (assert (not (null found-color)))
                               (color-number found-color)))))
                      (t
                       (loop :for color :across *colors*
                             :do (when (string= string (color-name color))
                                   (return (color-number color)))
                             :finally (return nil))))))
    (or color 0)))

(defun get-color-pair (fg-color-name bg-color-name)
  (let ((fg-color (if (null fg-color-name) -1 (get-color fg-color-name)))
        (bg-color (if (null bg-color-name) -1 (get-color bg-color-name))))
    (cond ((gethash (cons fg-color bg-color) *color-pair-table*))
          ((< *pair-counter* *color-pairs*)
           (init-pair fg-color bg-color))
          (t 0))))

#+(or)
(defun get-color-content (n)
  (cffi:with-foreign-pointer (r (cffi:foreign-type-size '(:pointer :short)))
    (cffi:with-foreign-pointer (g (cffi:foreign-type-size '(:pointer :short)))
      (cffi:with-foreign-pointer (b (cffi:foreign-type-size '(:pointer :short)))
        (charms/ll:color-content n r g b)
        (list (cffi:mem-ref r :short)
              (cffi:mem-ref g :short)
              (cffi:mem-ref b :short))))))

(defun get-default-colors ()
  (cffi:with-foreign-pointer (f (cffi:foreign-type-size '(:pointer :short)))
    (cffi:with-foreign-pointer (b (cffi:foreign-type-size '(:pointer :short)))
      (charms/ll:pair-content 0 f b)
      (values (cffi:mem-ref f :short)
              (cffi:mem-ref b :short)))))

(defun set-default-color (foreground background)
  (let ((fg-color (if foreground (get-color foreground) -1))
        (bg-color (if background (get-color background) -1)))
    (charms/ll:assume-default-colors fg-color
                                     bg-color)))

(defun background-mode ()
  (let ((b (nth-value 1 (get-default-colors))))
    (cond ((= b -1) :light)
          (t
           (let ((color (aref *colors* b)))
             (let ((r (color-r color))
                   (g (color-g color))
                   (b (color-b color)))
               (if (< 50 (/ (max r g b) 2.55))
                   :light
                   :dark)))))))

;;;


(let ((raw-mode))
  (defun raw-p ()
    raw-mode)
  (defun raw ()
    (setq raw-mode t)
    (charms/ll:raw))
  (defun noraw ()
    (setq raw-mode nil)
    (charms/ll:noraw)))

(defmacro with-raw (raw-p &body body)
  (let ((g-old-raw (gensym))
        (g-new-raw (gensym)))
    `(let ((,g-old-raw (raw-p))
           (,g-new-raw ,raw-p))
       (if ,g-new-raw
           (raw)
           (noraw))
       (unwind-protect (progn ,@body)
         (if ,g-old-raw
             (raw)
             (noraw))))))

;;;

(cffi:defcfun "fopen" :pointer (path :string) (mode :string))
(cffi:defcfun "fclose" :int (fp :pointer))
(cffi:defcfun "fileno" :int (fd :pointer))

(cffi:defcstruct winsize
  (ws-row :unsigned-short)
  (ws-col :unsigned-short)
  (ws-xpixel :unsigned-short)
  (ws-ypixel :unsigned-short))

(cffi:defcfun ioctl :int
  (fd :int)
  (cmd :int)
  &rest)

(defvar *tty-name* nil)
(defvar *term-io* nil)

(defun resize-term ()
  (when *term-io*
    (cffi:with-foreign-object (ws '(:struct winsize))
      (when (= 0 (ioctl (fileno *term-io*) 21523 :pointer ws))
        (cffi:with-foreign-slots ((ws-row ws-col) ws (:struct winsize))
          (charms/ll:resizeterm ws-row ws-col))))))

(defun term-init-tty (tty-name)
  (let* ((io (fopen tty-name "r+")))
    (setf *term-io* io)
    (cffi:with-foreign-string (term "xterm")
      (charms/ll:newterm term io io))))

(defun term-init ()
  (if *tty-name*
      (term-init-tty *tty-name*)
      (charms/ll:initscr))
  (init-colors)
  (charms/ll:noecho)
  (charms/ll:cbreak)
  (raw)
  (charms/ll:nonl)
  (charms/ll:refresh)
  (charms/ll:keypad charms/ll:*stdscr* 1))

(defun term-set-tty (tty-name)
  (setf *tty-name* tty-name))

(defun term-finalize ()
  (when *term-io*
    (fclose *term-io*)
    (setf *term-io* nil))
  (charms/ll:endwin)
  (charms/ll:delscreen charms/ll:*stdscr*))
